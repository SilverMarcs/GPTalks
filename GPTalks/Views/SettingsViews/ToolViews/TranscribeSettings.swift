//
//  TranscribeSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI
import SwiftData

struct TranscribeSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    @Bindable var providerDefaults: ProviderDefaults
    
    @Query(filter: #Predicate<Provider> { $0.isEnabled})
    var providers: [Provider]
    
    var body: some View {
        Section("General") {
            Toggle("Enabled for new chats", isOn: $config.transcribe)
        }
        
        Section("Defaults") {
            ProviderPicker(provider: $providerDefaults.sttProvider, providers: providers)
            
            ModelPicker(model: $providerDefaults.sttProvider.sttModel, models: providerDefaults.sttProvider.sttModels, label: "Transcription Model")
        }
        
        Section("Schema") {
            MarkdownView(content: ChatTool.transcribe.jsonSchemaString)
                .padding(.bottom, -11)
        }
    }
}

#Preview {
    TranscribeSettings(providerDefaults: .mockProviderDefaults)
}
