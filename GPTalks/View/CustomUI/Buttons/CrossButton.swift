//
//  CrossButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI

struct CrossButton: View {
    var cross: () -> Void
    
    var body: some View {
        Button {
            cross()
        } label: {
            Image(systemName: "xmark")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .keyboardShortcut(.cancelAction)
        .buttonStyle(.plain)
    }
}

#Preview {
    CrossButton() {}
}
