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
    
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
    @Bindable var providerDefaults: ProviderDefaults
    
    var filteredProviders: [Provider] {
        providers.filter { !$0.sttModels.isEmpty }
    }
    
    var body: some View {
        Section("General") {
            Toggle("Enabled for new chats", isOn: $config.transcribe)
        }
        
        Section("Defaults") {
            ProviderPicker(provider: $providerDefaults.toolSTTProvider, providers: filteredProviders)
            
            ModelPicker(model: $providerDefaults.toolSTTProvider.sttModel, models: providerDefaults.toolSTTProvider.sttModels, label: "STT Model")
        }
    }
}

#Preview {
    TranscribeSettings(providerDefaults: .mockProviderDefaults)
}
