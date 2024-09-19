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
    @ObservedObject var providerManager = ProviderManager.shared
    
    @Query(filter: #Predicate { $0.isEnabled && $0.supportsImage}, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]

    private var providerBinding: Binding<Provider?> {
        Binding<Provider?>(
            get: {
                self.providerManager.getImageProvider(providers: self.providers)
            },
            set: { newValue in
                if let provider = newValue {
                    self.providerManager.imageProvider = provider.id.uuidString
                }
            }
        )
    }
    
    var body: some View {
        Form {
            Section("Defaults") {
                Picker("Provider", selection: providerBinding) {
                    ForEach(providers) { provider in
                        Text(provider.name).tag(provider)
                    }
                }
                
                if let provider = providerBinding.wrappedValue {
                    Picker("Model", selection: Binding(
                        get: { provider.imageModel },
                        set: { newValue in
                            if let index = providers.firstIndex(where: { $0.id == provider.id }) {
                                providers[index].imageModel = newValue
                            }
                        }
                    )) {
                        ForEach(provider.imageModels) { model in
                            Text(model.name).tag(model)
                        }
                    }
                }
            }
            
            Section("Size") {
                IntegerStepper(value: $imageConfig.imageHeight, label: "Image Height", step: 30, range: 40...300)
                
                IntegerStepper(value: $imageConfig.imageWidth, label: "Image Width", step: 30, range: 80...300)
            }
            
            Section(header: Text("Default Parameters")) {
                Stepper(
                    "Number of Images",
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
    }
}

#Preview {
    ImageSettings()
}
