//
//  PlusButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct PlusButton: View {
    var size: CGFloat = 25
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: size, height: size)
                .foregroundStyle(.primary, .clear)
        }
        .keyboardShortcut("i", modifiers: .command)
        .buttonStyle(.plain)

    }
}

struct PlusImage: View {
    var size: CGFloat = 33
    
    var body: some View {
        Image(systemName: "plus.circle.fill")
            .resizable()
            .frame(width: size, height: size)
            .fontWeight(.light)
        #if os(macOS)
            .foregroundStyle(.secondary, .quinary)
        #else
            .foregroundStyle(.secondary, Color.gray.opacity(0.2))
        #endif
    }
}

#Preview {
    PlusButton() { }
        .padding()
}
