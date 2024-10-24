//
//  ModelListView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ModelList<M: ModelType>: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Bindable var provider: Provider
    @Binding var models: [M]

    @State private var showAdder = false
    @State private var showModelSelectionSheet = false
    @State private var selections: Set<M.ID> = []
        
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
            Menu {
                addButton
                refreshButton
            } label: {
                Label("Add Model", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showAdder) {
            AddModelSheet<M>(models: $models)
        }
        .sheet(isPresented: $showModelSelectionSheet) {
            ModelSelectionSheet(provider: provider)
        }
    }

    @ViewBuilder
    var table: some View {
        if horizontalSizeClass == .compact {
            List {
                ForEach($models) { $model in
                    HStack {
                        VStack {
                            TextField("Name", text: $model.name)
                            
                            TextField("Code", text: $model.code)
                        }
                        
                        Spacer()
                        
                        if let _ = model as? ChatModel {
                            ModelTester(provider: provider, model: $model)
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    models.remove(atOffsets: indexSet)
                })
            }
        } else {
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
                        if let _ = model as? ChatModel {
                            ModelTester(provider: provider, model: $model)
                        }
                        
                        Button {
                            models.removeAll(where: { $0.id == model.id })
                        } label: {
                            Image(systemName: "minus.circle.fill")
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
    }
    
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
