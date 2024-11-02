//
//  GenerateImageSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI
import SwiftData

struct GenerateImageSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    
    @Query(filter: #Predicate<Provider> { $0.isEnabled })
    var providers: [Provider]
    
    var filteredProviders: [Provider] {
        providers.filter { !$0.imageModels.isEmpty }
    }
    
    @Bindable var providerDefaults: ProviderDefaults
    
    var body: some View {
        Section("General") {
            Toggle("Enabled for new chats", isOn: $config.imageGenerate)
        }
        
        Section("Defaults") {            
            ProviderPicker(provider: $providerDefaults.imageProvider, providers: filteredProviders)
            
            ModelPicker(model: $providerDefaults.imageProvider.imageModel, models: providerDefaults.imageProvider.imageModels, label: "Image Model")
        }
    }
}

#Preview {
    GenerateImageSettings(providerDefaults: .mockProviderDefaults)
}
