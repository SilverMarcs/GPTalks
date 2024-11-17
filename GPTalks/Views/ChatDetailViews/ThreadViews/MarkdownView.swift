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

    var body: some View {
        switch config.markdownProvider {
        case .native:
            AttributedText(text: content, highlightText: chatVM.searchText, parseMarkdown: true) // uses my basic markdown parser
                .textSelection(.enabled)
        case .webview:
            SwiftMarkdownView(content)
                .markdownBaseURL("GPTalks Web Content")
                .markdownHighlightString(chatVM.searchText)
                .markdownFontSize(CGFloat(config.fontSize))
                .renderSkeleton(config.renderSkeleton)
                .codeBlockTheme(config.codeBlockTheme)
        }
    }
}

#Preview {
    MarkdownView(content: Thread.mockAssistantThread.content)
        .frame(width: 600, height: 500)
        .padding()
}
