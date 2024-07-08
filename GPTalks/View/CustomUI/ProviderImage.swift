//
//  ProviderImage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ProviderImage: View {
    var radius: CGFloat = 10
    var color: Color = .primary
    var frame: CGFloat = 29
    
    var body: some View {
        ZStack  {
            Image("openaiPng")
                .resizable()
                .frame(width: frame - 2, height: frame - 2)
                .colorMultiply(color)
        }
    }
}
#Preview {
    ProviderImage()
}
