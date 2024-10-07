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
    #if !os(macOS)
    @Environment(\.editMode) var editMode
    #endif
    @Bindable var provider: Provider
    @Binding var models: [M]

    @State private var showAdder = false
    @State private var showModelSelectionSheet = false

        
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
                    VStack {
                        TextField("Name", text: $model.name)
                            
                        TextField("Code", text: $model.code)
                    }
                }
                .onDelete(perform: { indexSet in
                    models.remove(atOffsets: indexSet)
                })
            }
        } else {
            Table($models) {
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
                        // TODO: add this
//                        if let model = model as? ChatModel {
//                            testModel(model: model)
//                        }
                        
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
    
    func testModel(model: ChatModel) -> some View {
        Button {
            Task {
                await provider.testModel(model: model)
            }
        } label: {
            Image(systemName: "play.cirle")
        }
    }
}

