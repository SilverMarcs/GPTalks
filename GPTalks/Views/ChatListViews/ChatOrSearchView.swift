//
//  ChatOrSearchView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/11/2024.
//

import SwiftUI

struct ChatOrSearchView: View {
    @Environment(ChatVM.self) var chatVM
    
    var body: some View {
        if (chatVM.isSearching || !chatVM.searchResults.isEmpty) || (chatVM.searchResults.isEmpty && !chatVM.searchText.isEmpty) {
            searchResultsView
                .navigationTitle("Search Results")
        } else {
            chatSessionView
        }
    }
    
    @ViewBuilder
    private var searchResultsView: some View {
        if chatVM.isSearching {
            ProgressView()
                .controlSize(.large)
                .navigationTitle("Searching")
                .fullScreenBackground()
        } else if chatVM.searchResults.isEmpty {
            ContentUnavailableView.search(text: chatVM.searchText)
                .fullScreenBackground()
        } else {
            searchResultsList
        }
    }
    
    @ViewBuilder
    private var searchResultsList: some View {
        List {
            ForEach(chatVM.searchResults) { result in
                Section("Session: \(result.chat.title)") {
                    VStack(spacing: 0) {
                        ForEach(result.matchedThreads) { matchedThread in
                            SearchResultRow(matchedThread: matchedThread)
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listSectionSeparator(.visible)
            
            Text("End of Search Results")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        }
    }
    
    @ViewBuilder
    private var chatSessionView: some View {
        if let chat = chatVM.activeChat, chat.status != .quick {
            ChatDetail(chat: chat)
                #if !os(macOS)
                .id(chat.id)
                #endif
        } else {
            Text("^[\(chatVM.selections.count) Chat Session](inflect: true) Selected")
                .font(.title)
                .fullScreenBackground()
        }
    }
}

#Preview {
    ChatOrSearchView()
}
