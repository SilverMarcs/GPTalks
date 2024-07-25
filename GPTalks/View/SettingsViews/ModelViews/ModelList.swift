//
//  ModelList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//


import SwiftUI

struct ModelList: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var provider: Provider
    
    @State var showAdder: Bool = false
    @State private var selections: Set<AIModel> = []
    
    var body: some View {
        content
            .sheet(isPresented: $showAdder) {
                ModelAdder(provider: provider)
            }
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Section {
                            PresetModelAdder(provider: provider)
                        }
                        
                        Button {
                            showAdder = true
                        } label: {
                            Label("Custom Model", systemImage: "plus")
                        }
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                    .fixedSize()
                }
            }
    }

    #if os(macOS)
    var content: some View {
        Form {
            List(selection: $selections) {
                Section(header:
                    HStack(spacing: 0) {
                        Image(systemName: "photo").frame(width: 20)
                            .offset(y: -1)
                        Text("Code").frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 17)
                        Text("Name").frame(maxWidth: .infinity, alignment: .leading)
                    }
                ) {
                    ModelCollection(provider: provider)
                }
            }
            .alternatingRowBackgrounds()
            .labelsHidden()
        }
        .formStyle(.grouped)
    }
    #else
    var content: some View {
        List {
            ModelCollection(provider: provider)
        }
    }
    #endif
}

#Preview {
    let provider = Provider.factory(type: .openai)

    NavigationStack {
        ModelList(provider: provider)
            .modelContainer(for: Provider.self, inMemory: true)
    }
}
