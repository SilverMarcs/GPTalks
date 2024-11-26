//
//  MessageRowiew.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
import SwiftMarkdownView

struct MarkdownView: View {
    @Environment(ChatVM.self) private var chatVM
    
    @ObservedObject var config = AppConfig.shared
    var content: String
    var calculatedHeight: Binding<CGFloat>? = nil

    var body: some View {
        switch config.markdownProvider {
        case .disabled:
            Text(content)
                .textSelection(.enabled)
                .font(.system(size: config.fontSize))
        case .native,
             .webview where !chatVM.searchText.isEmpty:
                NativeMarkdown(text: content, highlightText: chatVM.searchText)
                    .textSelection(.enabled)
        case .webview:
            SwiftMarkdownView(content, calculatedHeight: calculatedHeight)
                .markdownBaseURL("GPTalks Web Content")
                .markdownHighlightString(chatVM.searchText)
                .markdownFontSize(CGFloat(config.fontSize))
                .codeBlockTheme(config.codeBlockTheme.toCodeBlockTheme())
        }
    }
}

#Preview {
    MarkdownView(content: Message.mockAssistantMessage.content)
        .frame(width: 600, height: 500)
        .padding()
}
