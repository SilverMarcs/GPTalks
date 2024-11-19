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
    @Query var providers: [Provider]
    @Query var providerDefaults: [ProviderDefaults]
    
    var body: some View {
        Group {
            #if os(macOS)
            Form {
                content
            }
            .formStyle(.grouped)
            #else
            content
            #endif
        }
        .toolbar {
            addButton
        }
    }
    
    var content: some View {
        List {
            ForEach(providers) { provider in
                NavigationLink(destination: ProviderDetail(provider: provider)) {
                    ProviderRow(provider: provider)
                }
                .deleteDisabled(provider.isPersistent)
            }
            .onDelete(perform: deleteProviders)
        }
        .navigationTitle("Providers")
        .toolbarTitleDisplayMode(.inline)
    }
    
    private var addButton: some View {
        Menu {
            Section(header: Text("Primary Providers")) {
                ForEach([ProviderType.openai, .google, .anthropic], id: \.self) { type in
                    Button(action: { addProvider(type: type) }) {
                        Label(type.name, image: type.imageName)
                    }
                    .labelStyle(.titleAndIcon)
                }
            }
            
            Section(header: Text("Other Providers")) {
                ForEach([ProviderType.openrouter, .github, .vertex, .groq, .xai, .mistral, .perplexity, .togetherai], id: \.self) { type in
                    Button(action: { addProvider(type: type) }) {
                        Label(type.name, image: type.imageName)
                    }
                    .labelStyle(.titleAndIcon)
                }
            }
            
            #if os(macOS)
            Section(header: Text("Local Providers")) {
                ForEach([ProviderType.lmstudio, .ollama], id: \.self) { type in
                    Button(action: { addProvider(type: type) }) {
                        Label(type.name, image: type.imageName)
                    }
                    .labelStyle(.titleAndIcon)
                }
            }
            #endif
            
            Section(header: Text("Custom")) {
                Button(action: { addProvider(type: .custom) }) {
                    Label(ProviderType.custom.name, image: ProviderType.custom.imageName)
                }
                .labelStyle(.titleAndIcon)
            }
        } label: {
            Label("Create Provider", systemImage: "plus")
        }

    }

    private func addProvider(type: ProviderType) {
        let newProvider = Provider.factory(type: type)
        modelContext.insert(newProvider)
    }
    
    private func deleteProviders(offsets: IndexSet) {
        var providersToDelete = offsets
        
        let fetchDescriptor = FetchDescriptor<ChatConfig>()
        guard let allChatConfigs = try? modelContext.fetch(fetchDescriptor) else {
            print("Failed to fetch ChatConfigs")
            return
        }
        
        let defaultProvider = providerDefaults.first!.defaultProvider
        
        for index in offsets {
            let providerToDelete = providers[index]
            
            if providerToDelete == defaultProvider {
                providersToDelete.remove(index)
            } else {
                for chatConfig in allChatConfigs where chatConfig.provider == providerToDelete {
                    chatConfig.provider = defaultProvider
                    chatConfig.model = chatConfig.provider.chatModel
                }
            }
        }
        
        for index in providersToDelete {
            modelContext.delete(providers[index])
        }
    }
}

#Preview {
    ProviderList()
        .modelContainer(for: Provider.self, inMemory: true)
}
