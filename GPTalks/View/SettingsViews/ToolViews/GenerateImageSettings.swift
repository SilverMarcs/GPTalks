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
    @Bindable var providerDefaults: ProviderDefaults
    
    @Query(filter: #Predicate<Provider> { $0.isEnabled && !$0.imageModels.isEmpty})
    var providers: [Provider]
    
    var body: some View {
        Section("General") {
            Toggle("Enabled for new chats", isOn: $config.imageGenerate)
        }
        
        Section("Defaults") {            
            ProviderPicker(provider: $providerDefaults.imageProvider, providers: providers)
            
            ModelPicker(model: $providerDefaults.imageProvider.toolImageModel, models: providerDefaults.imageProvider.imageModels, label: "Image Model")
        }
    }
}

#Preview {
    GenerateImageSettings(providerDefaults: .mockProviderDefaults)
}
