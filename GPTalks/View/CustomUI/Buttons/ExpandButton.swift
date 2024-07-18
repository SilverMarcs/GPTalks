//
//  ExpandButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI

struct ExpandButton: View {
    var size: CGFloat = 25
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "arrow.down.left.and.arrow.up.right")
                .resizable()
                .scaledToFit()
                .padding(size * 0.3)
                .frame(width: size, height: size)
                .background(Material.bar)
                .clipShape(Circle())
                .foregroundStyle(.secondary, .quinary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExpandButton(action: {})
}
