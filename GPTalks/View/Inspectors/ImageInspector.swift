//
//  ImageInspector.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData
import OpenAI

struct ImageInspector: View {
    @Bindable var session: ImageSession
    @Query var providers: [Provider]
    
    var body: some View {
        Form {
            ProviderPicker(provider: $session.config.provider, providers: providers) { provider in
                print(provider.name)
            }
            
            ModelPicker(model: $session.config.model, models: session.config.provider.imageModels)
            
            Picker("N", selection: $session.config.numImages) {
                ForEach(1 ... 4, id: \.self) { num in
                    Text("n: " + String(num)).tag(num)
                }
            }
        }
    }
}

//#Preview {
//    ImageInspector()
//}
