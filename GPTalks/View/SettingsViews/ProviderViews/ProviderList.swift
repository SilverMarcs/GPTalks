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
    @Query var providerDefaults: [ProviderDefaults]
    
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
                .deleteDisabled(provider.isPersistent)
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
            Section(header: Text("Primary Providers")) {
                ForEach([ProviderType.openai, .google, .anthropic, .vertex], id: \.self) { type in
                    Button(action: { addProvider(type: type) }) {
                        Label(type.name, image: type.imageName)
                    }
                }
            }
            
            Section(header: Text("Other Providers")) {
                ForEach([ProviderType.openrouter, .groq, .mistral, .perplexity, .togetherai], id: \.self) { type in
                    Button(action: { addProvider(type: type) }) {
                        Label(type.name, image: type.imageName)
                    }
                }
            }
            
            #if os(macOS)
            Section(header: Text("Local Providers")) {
                ForEach([ProviderType.lmstudio, .ollama], id: \.self) { type in
                    Button(action: { addProvider(type: type) }) {
                        Label(type.name, image: type.imageName)
                    }
                }
            }
            #endif
            
            Section(header: Text("Custom")) {
                Button(action: { addProvider(type: .custom) }) {
                    Label(ProviderType.custom.name, image: ProviderType.custom.imageName)
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
            DispatchQueue.main.async {
                selectedProvider = newProvider
            }
        }
    }
    
    private func deleteProviders(offsets: IndexSet) {
        var providersToDelete = offsets
        
        let fetchDescriptor = FetchDescriptor<SessionConfig>()
        guard let allSessionConfigs = try? modelContext.fetch(fetchDescriptor) else {
            print("Failed to fetch SessionConfigs")
            return
        }
        
        let defaultProvider = providerDefaults.first!.defaultProvider
        
        for index in offsets {
            let providerToDelete = reorderedProviders[index]
            
            if providerToDelete.isPersistent || providerToDelete == defaultProvider {
                providersToDelete.remove(index)
            } else {
                for sessionConfig in allSessionConfigs where sessionConfig.provider == providerToDelete {
                    sessionConfig.provider = defaultProvider
                    sessionConfig.model = sessionConfig.provider.chatModel
                }
            }
        }
        
        for index in providersToDelete {
            modelContext.delete(reorderedProviders[index])
        }
        
        reorderProviders()
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
    }
}

#Preview {
    ProviderList()
        .modelContainer(for: Provider.self, inMemory: true)
}
