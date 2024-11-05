//
//  ModelListView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ModelList: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Bindable var provider: Provider
    @Binding var models: [AIModel]

    @State private var showAdder = false
    @State private var showModelSelectionSheet = false
    @State private var selections: Set<AIModel.ID> = []
    
    var body: some View {
        Group {
            #if os(macOS)
            Form {
                table
            }
            .formStyle(.grouped)
            .labelsHidden()
            #else
            list
            #endif
        }
        .toolbar {
            Menu {
                addButton
                refreshButton
            } label: {
                Label("Add Model", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showAdder) {
            ModelAdder(provider: provider)
        }
        .sheet(isPresented: $showModelSelectionSheet) {
            ModelRefresher(provider: provider)
        }
    }
    
    #if !os(macOS)
    var list: some View {
        List {
            ForEach($models) { $model in
                HStack {
                    VStack {
                        TextField("Name", text: $model.name)
                            
                        TextField("Code", text: $model.code)
                    }
                    .labelStyle(.titleOnly)
                    
                    Spacer()
                    
                    if model.type == .chat {
                        ModelTester(provider: provider, model: model)
                    }
                }
            }
            .onDelete(perform: { indexSet in
                models.remove(atOffsets: indexSet)
            })
        }
    }
    #endif
    
    #if os(macOS)
    var table: some View {
        Table($models, selection: $selections) {
            TableColumn("Code") { $model in
                TextField("Code", text: $model.code)
            }
            .width(250)
            .alignment(.leading)
            
            TableColumn("Name") { $model in
                TextField("Name", text: $model.name)
            }
            .width(200)
            
            TableColumn("Actions") { $model in
                HStack {
                    if model.type == .chat {
                        ModelTester(provider: provider, model: model)
                    }
                    
                    Button(role: .destructive) {
                        models.removeAll(where: { $0.id == model.id })
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            .alignment(.trailing)
        }
        .onDeleteCommand {
            models.removeAll(where: { selections.contains($0.id) })
        }
    }
    #endif

    var addButton: some View {
        Button(action: { showAdder = true }) {
            Label("Add Model", systemImage: "plus")
        }
    }
    
    var refreshButton: some View {
        Button(action: { showModelSelectionSheet = true }) {
            Label("Refresh Models", systemImage: "arrow.triangle.2.circlepath")
        }
    }
}
