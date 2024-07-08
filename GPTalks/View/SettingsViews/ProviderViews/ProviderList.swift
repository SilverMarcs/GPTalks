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
    @Query(sort: \Provider.date) var providers: [Provider]
    @ObservedObject var providerManager = ProviderManager.shared
    
    @State var selectedProvider: Provider?
    
    var body: some View {
        NavigationView {
            List(selection: $selectedProvider) {
                ForEach(providers, id: \.self) { provider in
                    NavigationLink(destination: ProviderDetail(provider: provider)) {
                        ProviderRow(provider: provider)
                    }
                }
                .onDelete(perform: deleteProviders)
            }
            .onAppear {
                DispatchQueue.main.async {
                    if selectedProvider == nil {
                        selectedProvider = providers.first
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button(action: addProvider) {
                        Label("Create Provider", systemImage: "plus")
                    }
                    .labelStyle(.iconOnly)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    private func addProvider() {
        let newProvider = Provider(name: "New Provider", host: "new-provider.com", apiKey: "")
        newProvider.addOpenAIModels()
        newProvider.chatModel = newProvider.models.first!
        
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
                if providers[index].id.uuidString == defaultProviderID {
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
}

#Preview {
    ProviderList()
        .modelContainer(for: Provider.self, inMemory: true)
}
