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
        Form {
            Section("Launch") {
                LabeledContent {
                    KeyboardShortcuts.Recorder(for: .togglePanel)
                } label: {
                    Text("Global shortcut")
                    Text("Access from anywhere in the OS")
                }
            }
            
            Section("LLM") {
                ProviderPicker(provider: $providerDefaults.quickProvider, providers: providers) { provider in
                    let statusId = ChatStatus.quick.id
                    
                    var descriptor = FetchDescriptor<Chat>(
                        predicate: #Predicate { $0.statusId == statusId }
                    )
                    
                    descriptor.fetchLimit = 1
                    
                    do {
                        let quickSessions = try modelContext.fetch(descriptor)
                        let chat = quickSessions.first
                        chat?.config.provider = provider
                        chat?.config.model = provider.liteModel
                    } catch {
                        print("Error fetching quick session: \(error)")
                    }
                }
                
                ModelPicker(model: $providerDefaults.quickProvider.liteModel, models: providerDefaults.quickProvider.chatModels, label: "Lite Model")
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
