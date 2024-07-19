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
        ForEach(generation.imagePaths, id: \.self) { path in
            ImageViewer(imagePath: path) {
                
            }
        }
    }
}

//#Preview {
//    ImageGenerationView()
//}
