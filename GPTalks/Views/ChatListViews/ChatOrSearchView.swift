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
                Section {
                    VStack(spacing: 0) {
                        ForEach(result.matchedThreads) { matchedThread in
                            ThreadView(thread: matchedThread.thread)
                                .environment(\.isSearch, true)
                        }
                    }
                } header: {
                    HStack {
                        Text("Session: \(result.chat.title)")
                        Spacer()
                        
                        Button {
                            chatVM.selections = [result.chat]
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
            .listRowSeparator(.hidden)
            .listSectionSeparator(.visible)
            
            Divider()
                .listRowSeparator(.hidden)
            
            Text("End of Search Results")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom)
                .listRowSeparator(.hidden)
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
