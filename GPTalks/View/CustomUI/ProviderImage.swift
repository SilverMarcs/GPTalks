//
//  ProviderImage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ProviderImage: View {
    var provider: Provider
    
    var radius: CGFloat = 9
    var frame: CGFloat = 29
    
    var body: some View {
        ZStack {
            // Background rounded rectangle
            RoundedRectangle(cornerRadius: radius)
                .fill(Color(hex: provider.color))
                .frame(width: frame, height: frame)
            
            // Image
            Image(provider.type.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: frame - provider.type.imageOffset,
                       height: frame - provider.type.imageOffset)
        }
    }
}

#Preview {
    ProviderImage(provider: Provider.factory(type: .openai))
}
