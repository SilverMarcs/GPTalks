//
//  QuickPanelSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/07/2024.
//

import KeyboardShortcuts
import SwiftUI
import SwiftData

struct QuickPanelSettings: View {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Provider> { $0.isEnabled })
    var providers: [Provider]
    @ObservedObject var config = AppConfig.shared

    @Bindable var providerDefaults: ProviderDefaults
    
    var body: some View {
        #if os(macOS)
        content
        #else
        EmptyView()
        #endif
    }
    
    var content: some View {
        Form {
            Section("Launch") {
                HStack {
                    Text("Shortcut")
                    Spacer()
                    #if os(macOS)
                    KeyboardShortcuts.Recorder(for: .togglePanel)
                    #endif
                }
            }
            
            Section("LLM") {
                ProviderPicker(provider: $providerDefaults.quickProvider, providers: providers) { provider in
                    var descriptor = FetchDescriptor<Chat>(
                        predicate: #Predicate { $0.isQuick == true }
                    )
                    
                    descriptor.fetchLimit = 1
                    
                    do {
                        let quickSessions = try modelContext.fetch(descriptor)
                        let session = quickSessions.first
                        session?.config.provider = provider
                        session?.config.model = provider.quickChatModel
                    } catch {
                        print("Error fetching quick session: \(error)")
                    }
                }
                
                ModelPicker(model: $providerDefaults.quickProvider.quickChatModel, models: providerDefaults.quickProvider.chatModels)
            }
                
            Section("System Prompt") {
                TextEditor(text: $config.quickSystemPrompt)
                    .font(.body)
                    .frame(height: 70)
                    .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Quick Panel")
        .formStyle(.grouped)
    }
}

#Preview {
    QuickPanelSettings(providerDefaults: .mockProviderDefaults)
}
