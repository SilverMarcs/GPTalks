//
//  ProviderPicker.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct ProviderPicker: View {
    @Binding var provider: Provider
    var providers: [Provider]
    var onChange: ((Provider) -> Void)?
    
    var body: some View {
        Picker("Provider", selection: $provider) {
            ForEach(providers) { provider in
                Text(provider.name)
                    .tag(provider)
            }
        }
        .onChange(of: provider) {
            onChange?(provider)
        }
    }
}
