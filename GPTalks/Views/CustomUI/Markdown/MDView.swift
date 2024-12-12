//
//  MDView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
import SwiftMarkdownView
//import MarkdownView

struct MDView: View {
    @Environment(\.searchText) private var searchText
    @Environment(\.isReplying) private var isReplying
    
    @ObservedObject var config = AppConfig.shared
    var content: String
    var calculatedHeight: Binding<CGFloat>? = nil

    var body: some View {
        switch config.markdownProvider {
        case .disabled:
            Text(content)
                .textSelection(.enabled)
                .font(.system(size: config.fontSize))
                .lineSpacing(2)
        case .basic:
//            MarkdownView(content: content)
//                .searchText(searchText)
//                .codeBlockFontSize(config.fontSize - 1)
//                .highlightCode(isReplying ? false : true)
//                .textSelection(.enabled)
//                .font(.system(size: config.fontSize))
//                .lineSpacing(2)
//            Text(LocalizedStringKey(content))
//                .textSelection(.enabled)
//                .font(.system(size: config.fontSize))
//                .lineSpacing(2)
//            NativeMarkdownView(text: content, highlightText: searchText)
            SimpleMarkdownView(text: content)
                .textSelection(.enabled)
                .lineSpacing(2)
                
        case .webview:
            SwiftMarkdownView(content, calculatedHeight: calculatedHeight)
                .markdownBaseURL("GPTalks Web Content")
                .markdownHighlightString(searchText)
                .markdownFontSize(CGFloat(config.fontSize))
                .codeBlockTheme(config.codeBlockTheme.toCodeBlockTheme())
        }
    }
}

#Preview {
    MDView(content: Message.mockAssistantMessage.content)
        .frame(width: 600, height: 500)
        .padding()
}
