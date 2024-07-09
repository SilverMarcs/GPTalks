//
//  PlusButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct PlusButton: View {
    var size: CGFloat = 25
    
    var body: some View {
        Button {

        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: size, height: size)
                .foregroundStyle(.secondary, .quinary)
        }
        .keyboardShortcut(.return, modifiers: .command)
        .buttonStyle(.plain)

    }
}

#Preview {
    PlusButton()
        .padding()
}
