//
//  MessageRowiew.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
import MarkdownWebView

struct MarkdownView: View {
    @Environment(\.isQuick) var isQuick
    @Environment(ChatSessionVM.self) private var sessionVM
    
    @ObservedObject var config = AppConfig.shared
    var content: String
    
    var highlightString: String? {
        sessionVM.searchText.count > 3 ? sessionVM.searchText : nil
    }
    
    var body: some View {
        let provider = isQuick ? config.quickMarkdownProvider : config.markdownProvider
        
        switch provider {
            case .webview:
                MarkdownWebView(content)
                    .markdownBaseURL("GPTalks Web Content")
                    .markdownHighlightString(highlightString)
                    .markdownTheme(config.markdownTheme)
                    .markdownFontSize(CGFloat(config.fontSize))

            case .native:
                Text(LocalizedStringKey(content))
                    .font(.system(size: config.fontSize))
                    .textSelection(.enabled)
                    #if os(macOS)
                    .lineSpacing(2)
                    #endif
            case .disabled:
                Text(content)
                    .font(.system(size: config.fontSize))
                    .textSelection(.enabled)
                    #if os(macOS)
                    .lineSpacing(2)
                    #endif
        }
    }
}



#Preview {
    MarkdownView(content: Conversation.mockAssistantConversation.content)
        .frame(width: 600, height: 500)
        .padding()
}
