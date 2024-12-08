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
    var type: ModelType

    @State private var showAdder = false
    @State private var showModelSelectionSheet = false
    
    var body: some View {
        Group {
            #if os(macOS)
            Form {
                list
            }
            .formStyle(.grouped)
            .labelsHidden()
            #else
            list
            #endif
        }
        .toolbar {
            Menu {
                Button(action: { showAdder = true }) {
                    Label("Add Model", systemImage: "plus")
                }
                
                Button(action: { showModelSelectionSheet = true }) {
                    Label("Refresh Models", systemImage: "arrow.triangle.2.circlepath")
                }
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
    
    @ViewBuilder
    var list: some View {
        if provider.models.filter({ $0.type == type }).isEmpty {
            Text("No models available")
        } else {
            List {
                ForEach(provider.models.filter { $0.type == type }, id: \.self) { model in
                    ModelRow(provider: provider, model: model)
                }
                .onDelete { indexSet in
                    // Create an array of the filtered models
                    let filteredModels = provider.models.filter { $0.type == type }
                    
                    // For each index in the indexSet, find the model in the filtered list
                    for index in indexSet {
                         let modelToDelete = filteredModels[index]
                        
                        // Find the index of the model in the original list and remove it
                        if let indexToDelete = provider.models.firstIndex(of: modelToDelete) {
                             provider.models.remove(at: indexToDelete)
                             modelContext.delete(modelToDelete)
                        }
                    }
                }
            }
        }
    }
}
