//
//  SearchResultRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/11/2024.
//

import SwiftUI
import MarkdownWebView

struct SearchResultRow: View {
    @Environment(ChatVM.self) var chatVM
    
    let matchedThread: MatchedThread
    
    var body: some View {
            HStack {
                ThreadView(conversation: matchedThread.conversation)
                    .environment(\.isSearch, true)
                
                Button {
                    chatVM.searchResults = []
                    chatVM.chatSelections = [matchedThread.session]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        matchedThread.session.proxy?.scrollTo(matchedThread.conversation.group, anchor: .top)
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
