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
        Text(generation.prompt)
            .padding(.vertical, 8)
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
                
        ForEach(generation.imagePaths, id: \.self) { path in
            ImageViewer(imagePath: path) {
            }
        }
        .frame(alignment: .leading)
    }
}

//#Preview {
//    ImageGenerationView()
//}
