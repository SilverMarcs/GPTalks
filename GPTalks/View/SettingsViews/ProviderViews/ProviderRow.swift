//
//  ProviderRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct ProviderRow: View {
    var provider: Provider
    @ObservedObject var selectionManager = ProviderManager.shared
    
    var body: some View {
        HStack {
            ProviderImage(provider: provider, radius: 6, frame: 20)
            Text(provider.name)
            Spacer()
            if selectionManager.defaultProvider == provider.id.uuidString {
                Image(systemName: "star.fill")
                    .imageScale(.small)
                    .foregroundStyle(.orange)
            }
        }
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
    let provider = Provider.factory(type: .openai)
    
    ProviderRow(provider: provider)
}
