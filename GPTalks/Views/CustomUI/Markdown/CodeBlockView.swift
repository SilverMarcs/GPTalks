//
//  CodeBlockView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI
import HighlightSwift

struct CodeBlockView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(ChatVM.self) var chatVM
    @Environment(\.isReplying) var isReplying
    @ObservedObject var config = AppConfig.shared
    
    let code: String
    let language: String?

    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
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
                .offset(y: -30) // Adjust this value as needed
                .padding(.bottom, -30) // This counteracts the offset to prevent extra space
        }
        #if os(macOS)
        .font(.system(size: AppConfig.shared.fontSize - 1, design: .monospaced))
        #else
        .font(.system(size: AppConfig.shared.fontSize - 5, design: .monospaced))
        #endif
        .roundedRectangleOverlay(radius: 6)
        .background(color.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
    }
    
    var color: Color {
        colorScheme == .dark ? .black : .gray
    }
}

#Preview {
    CodeBlockView(code: .codeBlock, language: "Swift")
        .padding()
        .environment(ChatVM.mockChatVM)
}
