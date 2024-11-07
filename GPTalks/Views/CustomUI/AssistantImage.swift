//
//  AssistantImage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 20/07/2024.
//

import SwiftUI

struct AssistantImage: View {
    let size: CGFloat
    
    var body: some View {
        Image(systemName: "sparkles")
            .resizable()
            .frame(width: size, height: size)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
                    .stroke(.tertiary, lineWidth: 1)
            )
    }
}

#Preview {
    AssistantImage(size: 10)
        .padding()
}
