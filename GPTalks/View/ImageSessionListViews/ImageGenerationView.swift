//
//  ImageGenerationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI

struct ImageGenerationView: View {
    var generation: ImageGeneration
    
    var body: some View {
        VStack(spacing: 10) {
            Text(generation.prompt)
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
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(alignment: .leading) {
                Text(generation.config.model.name)
                .foregroundStyle(.accent)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 5)
                
                if generation.state == .error {
                    Text(generation.errorMessage)
                        .foregroundStyle(.red)
                } else {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            if generation.state == .generating {
                                ForEach(1 ... generation.config.numImages, id: \.self) { image in
                                    ProgressView()
                                        .frame(width: 250, height: 250)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                            #if os(macOS)
                                                .fill(.background.quinary)
                                            #else
                                                .fill(.background.secondary)
                                            #endif
                                        )}

                                
                            } else if generation.state == .success {
                                ForEach(generation.imagePaths, id: \.self) { path in
                                    ImageViewer(imagePath: path, maxWidth: 250, maxHeight: 250, isCrossable: false) { }
                                }
                            }
                        }
                    }
                }
            }
        }
        .contextMenu {
            Button {
                generation.deleteSelf()
            } label: {
                Label("Delete Generation", systemImage: "trash")
            }
        }
    }
    
    var size: CGFloat {
        #if os(macOS)
        10
        #else
        10
        #endif
    }
}

//#Preview {
//    ImageGenerationView()
//}
