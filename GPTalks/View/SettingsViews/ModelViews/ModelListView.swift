//
//  ModelListView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ModelListView<M: ModelType>: View {
    @Environment(\.modelContext) var modelContext
    #if !os(macOS)
    @Environment(\.editMode) var editMode
    #endif
    @Bindable var provider: Provider
    @Binding var models: [M]

    @State private var showAdder = false
    @State private var showModelSelectionSheet = false
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
    #else
    private let isCompact = false
    #endif
        
    var body: some View {
        Group {
#if os(macOS)
            Form {
                table
            }
            .formStyle(.grouped)
            .labelsHidden()
#else
            table
#endif
        }
        .toolbar {
            refreshButton
            addButton
        }
        .sheet(isPresented: $showAdder) {
            AddModelSheet<M>(models: $models)
        }
        .sheet(isPresented: $showModelSelectionSheet) {
            ModelSelectionSheet(provider: provider)
        }
    }

    var table: some View {
        Table($models) {
            TableColumn("Code") { $model in
                HStack {
                    TextField("Code", text: $model.code)
                    
                    if isCompact {
                        Spacer()
                        Button {
                            models.removeAll(where: { $0.id == model.id })
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            #if os(macOS)
            .width(250)
            #endif
            .alignment(.leading)
            
            TableColumn("Name") { $model in
                TextField("Name", text: $model.name)
            }
            .width(200)
            
            TableColumn("Action") { model in
                Button {
                    models.removeAll(where: { $0.id == model.id })
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.red)
                }
            }
            .alignment(.trailing)
        }
    }
    
    var addButton: some View {
        Button(action: { showAdder = true }) {
            Label("Add Model", systemImage: "plus")
        }
    }
    
    var refreshButton: some View {
        Button {
            showModelSelectionSheet = true
        } label: {
            Label("Refresh Models", systemImage: "arrow.triangle.2.circlepath")
        }
    }
}

