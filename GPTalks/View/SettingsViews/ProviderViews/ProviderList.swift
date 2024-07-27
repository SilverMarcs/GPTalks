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
        NavigationStack {
            content
        }
        .toolbar {
            addButton
        }
    }

    var content: some View {
        Group {
            #if os(macOS)
            Form {
                providerSection(isEnabled: true)
                providerSection(isEnabled: false)
            }
            .formStyle(.grouped)
            #else
            List(selection: $selectedProvider) {
                providerSection(isEnabled: true)
                providerSection(isEnabled: false)
            }
            #endif
        }
        .navigationTitle("Providers")
        .toolbarTitleDisplayMode(.inline)
    }

    func providerSection(isEnabled: Bool) -> some View {
        Section(header: Text(isEnabled ? "Enabled" : "Disabled")) {
            #if os(macOS)
            List {
                providerList(isEnabled: isEnabled)
            }
            #else
            providerList(isEnabled: isEnabled)
            #endif
        }
    }

    func providerList(isEnabled: Bool) -> some View {
        ForEach(providers.filter { $0.isEnabled == isEnabled }, id: \.self) { provider in
            NavigationLink(destination: ProviderDetail(provider: provider)) {
                ProviderRow(provider: provider)
            }
        }
        .onDelete(perform: deleteProviders)
        .onMove(perform: move)
    }
    
    private var addButton: some View {
        Menu {
            ForEach(ProviderType.allCases, id: \.self) { type in
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
            for provider in providers {
                provider.order += 1
            }
            
            newProvider.order = 0
            modelContext.insert(newProvider)
        } completion: {
            selectedProvider = newProvider
            try? modelContext.save()
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
        } completion: {
            try? modelContext.save()
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        var updatedProviders = providers
        updatedProviders.move(fromOffsets: source, toOffset: destination)
        
        for (index, provider) in updatedProviders.enumerated() {
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
