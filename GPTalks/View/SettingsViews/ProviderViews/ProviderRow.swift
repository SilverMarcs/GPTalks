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
            ProviderImage(radius: 7, color: Color(hex: provider.color), frame: 20)
            Text(provider.name)
            Spacer()
            if selectionManager.defaultProvider == provider.id.uuidString {
                Image(systemName: "star.fill")
                    .imageScale(.small)
                    .foregroundStyle(.orange)
            }
        }
    }
}

#Preview {
    let provider = Provider.getDemoProvider()
    
    ProviderRow(provider: provider)
}
