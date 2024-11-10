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
    
    var list: some View {
        List {
            ForEach(provider.models.filter { $0.type == type }, id: \.self) { model in
                ModelRow(provider: provider, model: model)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(provider.models[index])
                }
            }
        }
    }
}
