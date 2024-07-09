//
//  CrossButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI

struct CrossButton: View {
    var size: CGFloat = 24
    var cross: () -> Void
    
    var body: some View {
        Button {
            cross()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: size, height: size)
                .fontWeight(.semibold)
                .foregroundStyle(.red)
        }
        .keyboardShortcut(.cancelAction)
        .buttonStyle(.plain)
        
    }
}

#Preview {
    CrossButton() {}
}
