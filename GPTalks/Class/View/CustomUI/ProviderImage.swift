//
//  ProviderImage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 21/12/2023.
//

import SwiftUI

struct ProviderImage: View {
    var radius: CGSize = CGSize(width: 10, height: 10)
    var color: Color = Color("greenColor")
    var frame: CGFloat = 36
    
    var body: some View {
        ZStack  {
            RoundedRectangle(cornerSize: radius)
                .fill(color)
                .frame(width: frame, height: frame)
            
            Image("openaiPng")
                .resizable()
                .frame(width: frame - 2, height: frame - 2)
        }
    }
}

#Preview {
    ProviderImage()
}
