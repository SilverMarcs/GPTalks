//
//  BedrockProviderHost.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/12/2024.
//

import SwiftUI

struct BedrockProviderHost: View {
    @ObservedObject var config: ChatConfigDefaults = .shared
    @Bindable var provider: Provider
    
    @State var showPopover: Bool = false
    
    var body: some View {
        LabeledContent {
            Text(config.bedrockRegion)
        } label: {
            Text("Region")
            Text("Only US is available at the moment")
        }
            
        SecretInputView(label: "Bedrock Access Key", secret: $config.bedrockAccessKey)
        SecretInputView(label: "Bedrock Secret Key", secret: $config.bedrockSecretKey)
    }
}

#Preview {
    BedrockProviderHost(provider: .openAIProvider)
}
