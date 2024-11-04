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

    var body: some View {
        MarkdownWebView(content)
            .markdownBaseURL("GPTalks Web Content")
            .markdownHighlightString(sessionVM.searchText)
            .markdownFontSize(CGFloat(config.fontSize))
    }
}



#Preview {
    MarkdownView(content: Conversation.mockAssistantConversation.content)
        .frame(width: 600, height: 500)
        .padding()
}
