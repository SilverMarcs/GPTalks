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
    
    @State private var selectedProviderId: String?
    
    var body: some View {
        Form {
            Section("Image Provider") {
                Picker("Default", selection: $selectedProviderId) {
                    ForEach(providers, id: \.id) { provider in
                        Text(provider.name).tag(provider.id.uuidString)
                    }
                }
                .onChange(of: selectedProviderId) {
                    providerManager.imageProvider = selectedProviderId
                }
                .onAppear {
                    selectedProviderId = providerManager.imageProvider
                }
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
