//
//  CustomCopyButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/11/2024.
//

import SwiftUI

struct CustomCopyButton: View {
    @State var clicked = false
    var content: String
    
    var body: some View {
        Button {
            withAnimation {
                clicked = true
            }
            content.copyToPasteboard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    clicked = false
                }
            }
        } label: {
            Image(systemName: clicked ? "checkmark" : "square.on.square")
                .imageScale(.medium)
                .bold()
                .frame(width: 12, height: 12)
                .padding(7)
                .contentShape(Rectangle())
        }
        .contentTransition(.symbolEffect(.replace))
        .buttonStyle(.borderless)
    }
}

#Preview {
    CustomCopyButton(content: "Copy this")
}
