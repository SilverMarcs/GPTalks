//
//  ImageUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct CustomImageViewModifier: ViewModifier {
    let padding: CGFloat
    let imageSize: CGFloat
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .foregroundStyle(.secondary)
            .background(color)
            .frame(width: imageSize, height: imageSize)
            .clipShape(Rectangle())
    }
}

extension Image {
    func customImageStyle(padding: CGFloat = 0, imageSize: CGFloat, color: Color = .clear) -> some View {
        self
            .resizable()
            .modifier(CustomImageViewModifier(padding: padding, imageSize: imageSize, color: color))
    }
}

#Preview {
    Image(systemName: "arrow.2.circlepath")
        .customImageStyle(imageSize: 20)
}
