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
                    chatVM.chatSelections = [matchedThread.chat]
                    chatVM.resetSearch()
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
