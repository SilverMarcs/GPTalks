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
    
    @State var isRendered = false
    
    var body: some View {
        switch config.markdownProvider {
            case .webview:
            if !isRendered {
                ProgressView()
            }
            
            MarkdownWebView(conversation.content,
                            baseURL: "GPTalks Web Content",
                            highlightString: highlightString,
                            customStylesheet: config.markdownTheme,
                            fontSize: CGFloat(config.fontSize))
            .onRendered { content in
                isRendered = true
            }
            case .native:
                Text(LocalizedStringKey(conversation.content))
                .font(.system(size: config.fontSize))
            case .disabled:
                Text(conversation.content)
                .font(.system(size: config.fontSize))
        }
    }
}
