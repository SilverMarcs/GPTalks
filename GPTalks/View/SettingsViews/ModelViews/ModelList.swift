//
//  ModelList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//


import SwiftUI

#if !os(macOS)
struct ModelList: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var provider: Provider
    
    @State var showAdder: Bool = false

    var body: some View {
        List {
            ModelCollection(provider: provider)
        }
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
}

#Preview {
    let provider = Provider.factory(type: .openai)

    NavigationStack {
        ModelList(provider: provider)
            .modelContainer(for: Provider.self, inMemory: true)
    }
}
#endif
