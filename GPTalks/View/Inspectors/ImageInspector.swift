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
            Section("Title") {
                TextField("Title", text: $session.title)
                    .labelsHidden()
            }
            
            Section("Models") {
                ProviderPicker(provider: $session.config.provider, providers: providers) { provider in
                    print(provider.name)
                }
                
                ModelPicker(model: $session.config.model, models: session.config.provider.imageModels)
            }
            
            Section("Parameters") {
                Picker("N", selection: $session.config.numImages) {
                    ForEach(1 ... 4, id: \.self) { num in
                        Text(String(num)).tag(num)
                    }
                }
                
                Picker("Quality", selection: $session.config.quality) {
                    ForEach(ImagesQuery.Quality.allCases, id: \.self) { quality in
                        Text(quality.rawValue.capitalized).tag(quality)
                    }
                }
                
                Picker("Size", selection: $session.config.size) {
                    ForEach(ImagesQuery.Size.allCases, id: \.self) { size in
                        Text(size.rawValue.capitalized).tag(size)
                    }
                }
                
                Picker("Style", selection: $session.config.style) {
                    ForEach(ImagesQuery.Style.allCases, id: \.self) { style in
                        Text(style.rawValue.capitalized).tag(style)
                    }
                }
            }
        }
    }
}

//#Preview {
//    ImageInspector()
//}
