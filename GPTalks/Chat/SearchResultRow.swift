//
//  SearchResultRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/11/2024.
//

import SwiftUI
import MarkdownWebView

struct SearchResultRow: View {
    @Environment(ChatSessionVM.self) var chatVM
    
    let conversation: SearchedConversation
    
    var body: some View {
            HStack {
                ConversationView(conversation: conversation.conversation)
                    .environment(\.isSearch, true)
                
                Button {
                    chatVM.sessionsWithMatches = []
                    chatVM.chatSelections = [conversation.session]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        conversation.session.proxy?.scrollTo(conversation.conversation.group, anchor: .top)
                    }
                } label: {
                    Image(systemName: "arrow.right")
                        .bold()
                        .imageScale(.large)
                        .foregroundStyle(.accent)
                }
                .buttonStyle(.plain)
            }
    }
}
