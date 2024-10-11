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
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
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
                ProviderPicker(provider: $providerDefaults.quickProvider, providers: providers)
                
                ModelPicker(model: $providerDefaults.quickProvider.quickChatModel, models: providerDefaults.quickProvider.chatModels)
            }

            Section("View") {
                Picker("Markdown Provider", selection: $config.quickMarkdownProvider) {
                    ForEach(MarkdownProvider.allCases, id: \.self) { provider in
                        Text(provider.name)
                    }
                }
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
