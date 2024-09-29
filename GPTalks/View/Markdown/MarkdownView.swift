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
    var conversation: Conversation
    
    var highlightString: String? {
        sessionVM.searchText.count > 3 ? sessionVM.searchText : nil
    }
    
    var body: some View {
        let provider = isQuick ? config.quickMarkdownProvider : config.markdownProvider
        
        switch provider {
            case .webview:
                MarkdownWebView(conversation.content,
                                baseURL: "GPTalks Web Content",
                                highlightString: highlightString,
                                customStylesheet: config.markdownTheme,
                                fontSize: CGFloat(config.fontSize))
            case .native:
                Text(LocalizedStringKey(conversation.content))
                    .font(.system(size: config.fontSize))
                    .textSelection(.enabled)
            case .disabled:
                Text(conversation.content)
                    .font(.system(size: config.fontSize))
                    .textSelection(.enabled)
        }
    }
}



#Preview {
    MarkdownView(conversation: .mockAssistantConversation)
        .frame(width: 600, height: 500)
        .padding()
}
