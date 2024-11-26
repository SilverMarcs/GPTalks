//
//  CodeBlockView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI
import HighlightSwift

struct CodeBlockView: View {
    @Environment(ChatVM.self) var chatVM
    
    let code: String
    let language: String?
    
    @State var clicked = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            CodeText(code)
                .codeTextColors(.theme(.github))
                .highlightedString(chatVM.searchText)
                .font(.system(size: AppConfig.shared.fontSize - 1, design: .monospaced))
                .padding()

            copyButton
                .padding(5)
        }
        .roundedRectangleOverlay(radius: 6)
        .background(.background.quinary.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
    }
    
    var copyButton: some View {
        Button {
            withAnimation {
                clicked = true
            }
            code.copyToPasteboard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    clicked = false
                }
            }
        } label: {
            Image(systemName: clicked ? "checkmark" : "square.on.square")
            .font(.system(size: 11))
            .frame(width: 11, height: 11)
            .padding(7)
            .contentShape(Rectangle())
        }
        .contentTransition(.symbolEffect(.replace))
        #if os(macOS)
        .background(
            .background.opacity(0.5),
            in: RoundedRectangle(cornerRadius: 5)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(.quaternary, lineWidth: 0.7)
        }
        #endif
        .buttonStyle(.borderless)
    }
}

#Preview {
    CodeBlockView(code: .codeBlock, language: "Swift")
        .padding()
        .environment(ChatVM.mockChatVM)
}
