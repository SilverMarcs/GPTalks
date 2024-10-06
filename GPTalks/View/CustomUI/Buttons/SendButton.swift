//
//  SendButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct SendButton: View {
    var size: CGFloat = 24
    var send: () -> Void
    
    var body: some View {
        Button {
            send()
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .frame(width: size, height: size)
                .fontWeight(.semibold)
                .foregroundStyle(.white, .accent)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SendButton(size: 24, send: {})
}
