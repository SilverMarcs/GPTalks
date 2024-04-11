//
//  ProviderImage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 21/12/2023.
//

import SwiftUI

struct ProviderImage: View {
    var radius: CGFloat = 10
    var color: Color = Color("greenColor")
    var frame: CGFloat = 36
    
    var body: some View {
        ZStack  {
            RoundedRectangle(cornerRadius: radius)
                .fill(color)
                .frame(width: frame, height: frame)
                .id(color)
            
            Image("openaiPng")
                .resizable()
                .frame(width: frame - 2, height: frame - 2)
//                .opacity(0.80)
        }
    }
}

#Preview {
    ProviderImage()
}
