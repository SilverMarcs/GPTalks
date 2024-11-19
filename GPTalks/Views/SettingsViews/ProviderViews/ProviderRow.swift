//
//  ProviderRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI
import SwiftData

struct ProviderRow: View {
    @Bindable var provider: Provider
    @Query var providerDefaults: [ProviderDefaults]
    
    var body: some View {
        HStack {
            ProviderImage(provider: provider, radius: 7, frame: 22, scale: .medium)
            Text(provider.name)
            Spacer()
            if providerDefaults.first!.defaultProvider == provider {
                Image(systemName: "star.fill")
                    .imageScale(.small)
                    .foregroundStyle(.orange)
            }
            #if os(macOS)
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
            #endif
        }
        #if os(macOS)
        .padding(5)
        #endif
        .opacity(provider.isEnabled ? 1 : 0.5)
        .swipeActions(edge: .leading) {
            Button(action: { provider.isEnabled.toggle() }) {
                Label("Toggle Enabled", systemImage: "power")
            }
        }
    }
}

#Preview {
    ProviderRow(provider: .openAIProvider)
}
