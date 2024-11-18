//
//  ImageGenOnboarding.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

struct ImageGenOnboarding: View {
    @Bindable var provider: Provider
    @ObservedObject var imageConfig = ImageConfigDefaults.shared
    
    var body: some View {
        GenericOnboardingView(
            icon: "photo.stack",
            iconColor: .indigo,
            title: "Generate Images with DALL-E",
            content: {
                Form {
                    Section {
                        ModelPicker(model: $provider.imageModel, models: provider.imageModels, label: "Default Model")
                        
                        Toggle(isOn: $imageConfig.saveToPhotos) {
                            Text("Save to Photos Library")
                            Text("Images will be saved to Downloads folder otherwise")
                        }
                    }
                    #if os(iOS)
                    .listRowBackground(Color(.secondarySystemBackground))
                    #endif
                }
            },
            footerText: "You may configure further in Settings."
        )
    }
}

#Preview {
    let provider = Provider.openAIProvider
    
    ImageGenOnboarding(provider: provider)
}
