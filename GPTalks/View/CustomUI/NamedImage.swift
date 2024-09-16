//
//  AssistantImage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 20/07/2024.
//

import SwiftUI

struct NamedImage: View {
    let size: CGFloat
    let name: String
    let provider: Provider?
    
    var body: some View {
        if let provider = provider {
            Image(provider.type.imageName)
                .resizable()
                .frame(width: size, height: size)
//                .padding(5)
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(.background)
//                        .stroke(.tertiary, lineWidth: 1)
//                )
        } else {
            Image(systemName: name)
                .resizable()
                .frame(width: size, height: size)
//                .padding(5)
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(.background)
//                        .stroke(.tertiary, lineWidth: 1)
//                )
        }
        

    }
}

#Preview {
    NamedImage(size: 10, name: "sparkles", provider: nil)
        .padding()
}
