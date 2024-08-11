//
//  MessageRowiew.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
import MarkdownWebView

struct MarkdownView: View {
    @ObservedObject var config = AppConfig.shared
    var conversation: Conversation
    
    var highlightString: String? {
        conversation.group?.session?.searchText.count ?? 0 > 3 ? conversation.group?.session?.searchText : nil
    }
    
    var body: some View {
        switch config.markdownProvider {
            case .webview:
            MarkdownWebView(conversation.content,
                            baseURL: "GPTalks Web Content",
                            highlightString: highlightString)
            case .native:
                Text(LocalizedStringKey(conversation.content))
            case .disabled:
                Text(conversation.content)
        }
    }
}
