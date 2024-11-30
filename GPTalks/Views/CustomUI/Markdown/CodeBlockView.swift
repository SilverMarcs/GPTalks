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
    @Environment(\.isReplying) var isReplying
    @ObservedObject var config = AppConfig.shared
    
    let code: String
    let language: String?

    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if isReplying {
                Text(code)
                    .padding()
            } else {
                CodeText(code)
                    .codeTextColors(.theme(config.codeBlockTheme.toHighlightTheme()))
                    .highlightedString(chatVM.searchText)
                    .padding()
            }
            
            CustomCopyButton(content: code)
                .padding(5)
        }
        .font(.system(size: AppConfig.shared.fontSize - 1, design: .monospaced))
        .roundedRectangleOverlay(radius: 6)
        .background(.background.quinary.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    CodeBlockView(code: .codeBlock, language: "Swift")
        .padding()
        .environment(ChatVM.mockChatVM)
}
