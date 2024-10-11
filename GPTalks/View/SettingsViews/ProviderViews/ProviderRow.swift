//
//  ProviderRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI
import SwiftData

struct ProviderRow: View {
    var provider: Provider
    @Query var providerDefaults: [ProviderDefaults]
    
    var body: some View {
        HStack {
            ProviderImage(provider: provider, radius: 6, frame: 18, scale: .small)
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
        .contentShape(Rectangle())
        #endif
        .opacity(provider.isEnabled ? 1 : 0.5)
    }
    
    private var size: CGFloat {
        #if os(macOS)
        return 16
        #else
        return 25
        #endif
    }
}

#Preview {
    ProviderRow(provider: .openAIProvider)
}
