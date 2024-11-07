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
    
    @State var selectedProvider: Provider?
    
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
            ProviderBackupSettings()
                .menuIndicator(.hidden)
            addButton
        }
    }
    
    var content: some View {
        List(selection: $selectedProvider) {
            ForEach(providers, id: \.self) { provider in
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
                }
            }
            
            Section(header: Text("Other Providers")) {
                ForEach([ProviderType.vertex, .openrouter, .groq, .xai, .mistral, .perplexity, .togetherai], id: \.self) { type in
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

    private func addProvider(type: ProviderType) {
        let newProvider = Provider.factory(type: type)
        
        withAnimation {
            modelContext.insert(newProvider)
        } completion: {
            DispatchQueue.main.async {
                selectedProvider = newProvider
            }
        }
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
                for sessionConfig in allChatConfigs where sessionConfig.provider == providerToDelete {
                    sessionConfig.provider = defaultProvider
                    sessionConfig.model = sessionConfig.provider.chatModel
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
