//
//  ProviderList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

extension AnyTransition {
    static var slideFromRight: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
}

struct ProviderList: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Provider.order) var providers: [Provider]
    @ObservedObject var providerManager = ProviderManager.shared
    
    @Binding var selectedProvider: Provider?
    @Binding var selectedSidebarItem: SidebarItem?
    
    var body: some View {
        Form {
            List(selection: $selectedProvider) {
                ForEach(providers, id: \.self) { provider in
                    Button {
                        selectedProvider = provider
                        selectedSidebarItem = .providerDetail(provider)
                    } label: {
                        ProviderRow(provider: provider)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: deleteProviders)
                .onMove(perform: move)
            }
        }
        .formStyle(.grouped)
        .toolbar {
            addButton
        }
    }
    
    private var addButton: some View {
        Menu {
            ForEach(ProviderType.allCases, id: \.self) { type in
                Button(action: { addProvider(type: type) }) {
                    Text(type.name)
                }
            }
        } label: {
            Label("Create Provider", systemImage: "plus")
        }
        .menuStyle(SimpleIconOnly())
    }
    
    private func addProvider(type: ProviderType) {
        let newProvider = Provider.factory(type: type)
        
        withAnimation {
            modelContext.insert(newProvider)
        }
        
        DispatchQueue.main.async {
            selectedProvider = newProvider
            if providerManager.defaultProvider == nil {
                providerManager.defaultProvider = newProvider.id.uuidString
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save Provider")
        }
    }
    
    private func deleteProviders(offsets: IndexSet) {
        withAnimation {
            let defaultProviderID = providerManager.defaultProvider
            var providersToDelete = offsets
            // Check if any of the selected providers is the default provider
            for index in offsets {
                if providers[index].id.uuidString == defaultProviderID && providers[index].name == "OpenAI" {
                    // Remove the default provider from the deletion set
                    providersToDelete.remove(index)
                }
            }
            // Delete the remaining providers
            for index in providersToDelete {
                modelContext.delete(providers[index])
            }
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        var updatedProviders = providers
        updatedProviders.move(fromOffsets: source, toOffset: destination)
        
        for (index, provider) in updatedProviders.enumerated() {
            provider.order = index
        }
        
        try? modelContext.save()
    }
}

#Preview {
    ProviderList(selectedProvider: .constant(nil), selectedSidebarItem: .constant(.providers))
        .modelContainer(for: Provider.self, inMemory: true)
}
