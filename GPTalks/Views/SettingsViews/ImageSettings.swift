//
//  ImageSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI
import SwiftData
import OpenAI

struct ImageSettings: View {
    @ObservedObject var imageConfig = ImageConfigDefaults.shared
    
    @Query(filter: #Predicate<Provider> { $0.isEnabled })
    var providers: [Provider]

    @Bindable var providerDefaults: ProviderDefaults
    
    var filteredProviders: [Provider] {
        providers.filter { !$0.imageModels.isEmpty }
    }
    
    var body: some View {
        Form {
            Toggle(isOn: $imageConfig.saveToPhotos) {
                Text("Save to Photos Library")
                Text("Images will be saved to Downloads folder otherwise")
            }
            
            Section("Models") {
                ProviderPicker(provider: $providerDefaults.imageProvider, providers: filteredProviders)
                
                ModelPicker(model: $providerDefaults.imageProvider.imageModel, models: providerDefaults.imageProvider.imageModels, label: "Model")
            }
            
            Section(header: Text("Default Parameters")) {
                Stepper(
                    "Number of Images (\(imageConfig.numImages))",
                    value: Binding<Double>(
                        get: { Double(imageConfig.numImages) },
                        set: { imageConfig.numImages = Int($0) }
                    ),
                    in: 1...4,
                    step: 1,
                    format: .number
                )
                
                
                Picker("Size", selection: $imageConfig.size) {
                    ForEach(ImagesQuery.Size.allCases, id: \.self) { size in
                        Text(size.rawValue)
                    }
                }
                
                Picker("Quality", selection: $imageConfig.quality) {
                    ForEach(ImagesQuery.Quality.allCases, id: \.self) { quality in
                        Text(quality.rawValue.uppercased())
                    }
                }
                
                Picker("Style", selection: $imageConfig.style) {
                    ForEach(ImagesQuery.Style.allCases, id: \.self) { style in
                        Text(style.rawValue.capitalized)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Image Gen")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    ImageSettings(providerDefaults: .mockProviderDefaults)
}
