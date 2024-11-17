//
//  APIKeyOnboarding.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI
import SwiftData

struct APIKeyOnboarding: View {
    @Bindable var providerDefault: ProviderDefaults
    
    @Query(filter: #Predicate<Provider> { $0.isEnabled })
    var providers: [Provider]
    
    var body: some View {
        GenericOnboardingView(
            icon: "cpu.fill",
            iconColor: Color(hex: providerDefault.defaultProvider.color),
            title: "Enter your API Key",
            content: {
                Form {
                    Section {
                        ProviderPicker(provider: $providerDefault.defaultProvider, providers: providers, label: "Default Provider")
                        
                        TextField("API Key", text: $providerDefault.defaultProvider.apiKey)
                    } footer: {
                        SectionFooterView(text: providerDefault.defaultProvider.type.extraInfo)
                    }
                }
                .scrollDisabled(true)
                .formStyle(.grouped)
            },
            footerText: "Configure other providers in Settings."
        )
    }
}

#Preview {
    var providerDefault = ProviderDefaults.mockProviderDefaults
    providerDefault.defaultProvider = Provider.openAIProvider
    
    return APIKeyOnboarding(providerDefault: providerDefault)

        .frame(width: 500, height: 500)
}
