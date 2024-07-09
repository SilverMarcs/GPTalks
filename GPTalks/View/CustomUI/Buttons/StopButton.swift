//
//  StopButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI

struct StopButton: View {
    var size: CGFloat = 24
    var stop: () -> Void
    
    var body: some View {
        Button {
            stop()
        } label: {
            Image(systemName: "stop.circle.fill")
                .resizable()
                .frame(width: size, height: size)
                .fontWeight(.semibold)
                .foregroundStyle(.red)
        }
        .keyboardShortcut("d")
        .buttonStyle(.plain)

    }
}

#Preview {
    StopButton() {
        
    }
}
