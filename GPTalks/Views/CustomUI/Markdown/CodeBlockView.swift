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
    @ObservedObject var config = AppConfig.shared
    
    let code: String
    let language: String?
    
    @State var clicked = false
    
    var body: some View {
//        ZStack(alignment: .bottomTrailing) {
            CodeText(code)
                .codeTextColors(.theme(config.codeBlockTheme.toHighlightTheme()))
                .highlightedString(chatVM.searchText)
                .font(.system(size: AppConfig.shared.fontSize - 1, design: .monospaced))
                .padding()

//            copyButton
//                .padding(5)
//        }
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
    CodeBlockView(code: .codeBlock, language: "Swift")
        .padding()
        .environment(ChatVM.mockChatVM)
}
