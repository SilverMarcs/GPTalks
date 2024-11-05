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
    
    let matchedConversation: MatchedConversation
    
    var body: some View {
            HStack {
                ConversationView(conversation: matchedConversation.conversation)
                    .environment(\.isSearch, true)
                
                Button {
                    chatVM.searchResults = []
                    chatVM.chatSelections = [matchedConversation.session]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        matchedConversation.session.proxy?.scrollTo(matchedConversation.conversation.group, anchor: .top)
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
