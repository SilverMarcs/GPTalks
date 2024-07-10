//
//  ImageViewer.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/07/2024.
//

import SwiftUI

struct ImageViewer: View {
    let imagePath: String
    let onRemove: () -> Void
    
    var maxWidth: CGFloat = 100
    var maxHeight: CGFloat = 100
    var radius: CGFloat = 7
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = Image(filePath: imagePath) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: radius))
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white)
                }
                .shadow(radius: 5)
                .buttonStyle(.plain)
                .padding(5)
            } else {
                
            }
        }
    }
    
    init(imagePath: String, maxWidth: CGFloat = 100, maxHeight: CGFloat = 100, radius: CGFloat = 7, onRemove: @escaping () -> Void) {
        self.imagePath = imagePath
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.radius = radius
        self.onRemove = onRemove
    }
}

#Preview {
    let path = "file:///Users/Zabir/Pictures/Screenshots/zdontdelete.png"
    
//    ImageViewer(imagePath: path, maxWidth: .infinity) {}
    ImageViewer(imagePath: path, maxWidth: .infinity) {}
}
