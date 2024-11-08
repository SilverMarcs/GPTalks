//
//  GenerationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI

struct GenerationView: View {
    @ObservedObject var imageConfig = ImageConfigDefaults.shared
    var generation: Generation
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()

                if generation.state == .generating {
                    ActionButton(isStop: true) {
                        generation.stopGenerating()
                    }
                }
                
                Text(generation.config.prompt)
                    .textSelection(.enabled)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                        #if os(macOS)
                            .fill(.background.quinary)
                        #else
                            .fill(.background.secondary)
                        #endif
                    )
            }
            
            
            VStack(alignment: .leading) {
                Text(generation.config.model.name)
                    .font(.caption)
                    .padding(.leading, 5)
                    .foregroundStyle(LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                
                if generation.state == .error {
                    Text(generation.errorMessage)
                        .textSelection(.enabled)
                        .foregroundStyle(.red)
                        .padding(.leading, 5)
                        .padding(.top, 1)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.fixed(CGFloat(imageConfig.imageHeight)), spacing: gridSpacing),
                        GridItem(.fixed(CGFloat(imageConfig.imageHeight)), spacing: gridSpacing),
                    ], alignment: .leading, spacing: gridSpacing) {
                        if generation.state == .generating {
                            ForEach(1 ... generation.config.numImages, id: \.self) { image in
                                ProgressView()
                                    .frame(width: CGFloat(imageConfig.imageWidth), height: CGFloat(imageConfig.imageHeight))
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                        #if os(macOS)
                                            .fill(.background.quinary)
                                        #else
                                            .fill(.background.secondary)
                                        #endif
                                    )
                            }
                        } else if generation.state == .success {
                            ForEach(generation.images, id: \.self) { image in
                                ImageViewerData(data: image)
                            }
                        }
                    }
                }
            }
        }
        .contentShape(.rect)
        .contextMenu {
            Button {
                generation.deleteSelf()
            } label: {
                Label("Delete Generation", systemImage: "trash")
            }
        }
    }
    
    var gridSpacing: CGFloat {
        #if os(macOS)
        10
        #else
        10
        #endif
    }
    
    var size: CGFloat {
        #if os(macOS)
        10
        #else
        10
        #endif
    }
}


#Preview {
    GenerationView(generation: .mockGeneration)
}
