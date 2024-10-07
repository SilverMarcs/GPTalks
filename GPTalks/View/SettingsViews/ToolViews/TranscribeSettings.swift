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
    @ObservedObject var providerManager: ProviderManager = .shared
    
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]

    private var providerBinding: Binding<Provider?> {
        Binding<Provider?>(
            get: {
                self.providerManager.getToolSTTProvider(providers: self.providers)
            },
            set: { newValue in
                if let provider = newValue {
                    self.providerManager.toolSTTProvider = provider.id.uuidString
                }
            }
        )
    }
    
    var body: some View {
        Section("General") {
            Toggle("Enabled for new chats", isOn: $config.transcribe)
        }
        
        Section("Defaults") {
            Picker("Provider", selection: providerBinding) {
                ForEach(providers) { provider in
                    Text(provider.name).tag(provider)
                }
            }
            
            if let provider = providerBinding.wrappedValue {
                Picker("Model", selection: Binding(
                    get: { provider.sttModel },
                    set: { newValue in
                        if let index = providers.firstIndex(where: { $0.id == provider.id }) {
                            providers[index].sttModel = newValue
                        }
                    }
                )) {
                    ForEach(provider.sttModels) { model in
                        Text(model.name).tag(model)
                    }
                }
            }
        }
    }
}

#Preview {
    TranscribeSettings()
}
