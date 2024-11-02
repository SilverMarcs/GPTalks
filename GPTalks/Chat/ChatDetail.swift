//
//  ChatDetail.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/11/2024.
//

import SwiftUI

struct ChatDetail: View {
    @Environment(ChatSessionVM.self) var chatVM
    
    var body: some View {
        if !chatVM.searchText.isEmpty {
            searchResultsView
                .navigationTitle("Search Results")
        } else {
            chatSessionView
        }
    }
    
    @ViewBuilder
    private var searchResultsView: some View {
        if chatVM.searching {
            ProgressView()
                .controlSize(.large)
                .navigationTitle("Searching")
                .fullScreenBackground()
        } else if chatVM.sessionsWithMatches.isEmpty {
            ContentUnavailableView.search(text: chatVM.searchText)
                .fullScreenBackground()
        } else {
            searchResultsList
        }
    }
    
    private var searchResultsList: some View {
        List {
            ForEach(chatVM.sessionsWithMatches) { sessionWithMatches in
                Section("Session: \(sessionWithMatches.session.title)") {
                    VStack(spacing: 0) {
                        ForEach(sessionWithMatches.matchingConversations) { conversation in
                            SearchResultRow(conversation: conversation)
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
            
            Text("End of Search Results")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        }
    }
    
    @ViewBuilder
    private var chatSessionView: some View {
        if let session = chatVM.activeSession, !session.isQuick {
            ConversationList(session: session)
                .id(session.id)
        } else {
            Text("^[\(chatVM.chatSelections.count) Chat Session](inflect: true) Selected")
                .font(.title)
                .fullScreenBackground()
        }
    }
}



struct FullScreenBackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background)
            .toolbarBackground(.hidden)
    }
}

extension View {
    func fullScreenBackground() -> some View {
        self.modifier(FullScreenBackgroundStyle())
    }
}


#Preview {
    ChatDetail()
}
