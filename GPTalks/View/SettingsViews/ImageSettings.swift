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
            Section {
                ProviderPicker(provider: $providerDefaults.imageProvider, providers: filteredProviders)
                
                ModelPicker(model: $providerDefaults.imageProvider.imageModel, models: providerDefaults.imageProvider.imageModels, label: "Image Model")
                
            } header: {
                Text("Defaults")
            } footer: {
                SectionFooterView(text: "Check Plugin Settings to configure models for plugin generations")
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
            
            Section("Generation Image Size") {
                IntegerStepper(value: $imageConfig.imageHeight, label: "Image Height", step: 50, range: 50...500)
                
                IntegerStepper(value: $imageConfig.imageWidth, label: "Image Width", step: 50, range: 50...500)
                
                HStack(alignment: .top) {
                    #if os(macOS)
                    Text("Only applies to images from Image Generation Session")
                    #endif
                    
                    Spacer()
                    
                    Image("sample")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: CGFloat(imageConfig.imageWidth), height: CGFloat(imageConfig.imageHeight))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
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
