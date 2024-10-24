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
    
    @Query(filter: #Predicate { $0.isEnabled && $0.supportsImage }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
    @Bindable var providerDefaults: ProviderDefaults
    
    var body: some View {
        Section("General") {
            Toggle("Enabled for new chats", isOn: $config.imageGenerate)
        }
        
        Section("Defaults") {            
            ProviderPicker(provider: $providerDefaults.imageProvider, providers: providers)
            
            ModelPicker(model: $providerDefaults.imageProvider.imageModel, models: providerDefaults.imageProvider.imageModels, label: "Image Model")
        }
    }
}

#Preview {
    GenerateImageSettings(providerDefaults: .mockProviderDefaults)
}
