//
//  ProviderList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct ProviderList: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Provider.order) var providers: [Provider]
    @ObservedObject var providerManager = ProviderManager.shared
    
    @State var selectedProvider: Provider?
    
    var body: some View {
        Group {
            #if os(macOS)
            NavigationStack {
                Form {
                    content
                }
                .formStyle(.grouped)
            }
            #else
            NavigationStack {
                content
            }
            #endif
        }
        .toolbar {
            addButton
        }
    }
    
    var content: some View {
        List(selection: $selectedProvider) {
            ForEach(reorderedProviders, id: \.self) { provider in
                NavigationLink(destination: ProviderDetail(provider: provider, reorderProviders: { self.reorderProviders() })) {
                    ProviderRow(provider: provider)
                }
            }
            .onDelete(perform: deleteProviders)
            .onMove(perform: move)
        }
        .navigationTitle("Providers")
        .toolbarTitleDisplayMode(.inline)
    }
    
    private var reorderedProviders: [Provider] {
        let enabled = providers.filter { $0.isEnabled }.sorted { $0.order < $1.order }
        let disabled = providers.filter { !$0.isEnabled }.sorted { $0.order < $1.order }
        return enabled + disabled
    }
    
    private var addButton: some View {
        Menu {
            ForEach(ProviderType.allTypes, id: \.self) { type in
                Button(action: { addProvider(type: type) }) {
                    Label(type.name, image: type.imageName)
                }
            }
        } label: {
            Label("Create Provider", systemImage: "plus")
        }
    }
}

extension ProviderList {
    private func addProvider(type: ProviderType) {
        let newProvider = Provider.factory(type: type)
        
        withAnimation {
            modelContext.insert(newProvider)
            reorderProviders()
        } completion: {
            try? modelContext.save()
            DispatchQueue.main.async {
                selectedProvider = newProvider
            }
        }
    }
    
    private func deleteProviders(offsets: IndexSet) {
        withAnimation {
            let defaultProviderID = providerManager.defaultProvider
            var providersToDelete = offsets
            for index in offsets {
                if reorderedProviders[index].id.uuidString == defaultProviderID || reorderedProviders[index].name == "OpenAI" {
                    providersToDelete.remove(index)
                }
            }
            for index in providersToDelete {
                modelContext.delete(reorderedProviders[index])
            }
            reorderProviders()
        } completion: {
            try? modelContext.save()
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        var updatedProviders = reorderedProviders
        updatedProviders.move(fromOffsets: source, toOffset: destination)
        reorderProviders(updatedProviders)
    }
    
    private func reorderProviders(_ customOrder: [Provider]? = nil) {
        let providersToReorder = customOrder ?? reorderedProviders
        for (index, provider) in providersToReorder.enumerated() {
            withAnimation {
                provider.order = index
            }
        }
        try? modelContext.save()
    }
}

#Preview {
    ProviderList()
        .modelContainer(for: Provider.self, inMemory: true)
}
