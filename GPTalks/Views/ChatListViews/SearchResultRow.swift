//
//  SearchResultRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/11/2024.
//

import SwiftUI

struct SearchResultRow: View {
    @Environment(ChatVM.self) var chatVM
    
    let matchedThread: MatchedThread
    
    var body: some View {
            HStack {
                ThreadView(thread: matchedThread.thread)
                    .environment(\.isSearch, true)
                
                Button {
                    chatVM.searchResults = []
                    chatVM.chatSelections = [matchedThread.chat]
                    chatVM.searching = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        matchedThread.chat.proxy?.scrollTo(matchedThread.thread, anchor: .top)
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
