//
//  QuickPanelSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/07/2024.
//

import KeyboardShortcuts
import SwiftUI
import SwiftData

#if os(macOS)
struct QuickPanelSettings: View {
    @Query var providers: [Provider]
    @ObservedObject var providerManager: ProviderManager = .shared
    @ObservedObject var config = AppConfig.shared

    private var providerBinding: Binding<Provider?> {
        Binding<Provider?>(
            get: {
                self.providerManager.getQuickProvider(providers: self.providers)
            },
            set: { newValue in
                if let provider = newValue {
                    self.providerManager.quickProvider = provider.id.uuidString
                }
            }
        )
    }
    
    var body: some View {
        Form {
            Section("Launch") {
                HStack {
                    Text("Shortcut")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .togglePanel)
                }
            }
            
            Section("LLM") {
                Picker("Provider", selection: providerBinding) {
                    ForEach(providers, id: \.id) { provider in
                        Text(provider.name).tag(provider as Provider?)
                    }
                }
                
                if let provider = providerBinding.wrappedValue {
                    Picker("Model", selection: Binding(
                        get: { provider.quickChatModel },
                        set: { newValue in
                            if let index = providers.firstIndex(where: { $0.id == provider.id }) {
                                providers[index].quickChatModel = newValue
                            }
                        }
                    )) {
                        ForEach(provider.models, id: \.self) { model in
                            Text(model.name).tag(model)
                        }
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
        .formStyle(.grouped)
    }
}

#Preview {
    QuickPanelSettings()
}
#endif
