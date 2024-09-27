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
    var frame: CGFloat = 25
    
    var scale: Image.Scale
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .fill(Color(hex: provider.color).gradient)
                .frame(width: frame, height: frame)

            Image(provider.type.imageName)
                .foregroundStyle(provider.type == .local ? .black : .white)
                .imageScale(scale)
        }
    }
}

#Preview {
    ProviderImage(provider: Provider.factory(type: .openai), scale: .small)
}
