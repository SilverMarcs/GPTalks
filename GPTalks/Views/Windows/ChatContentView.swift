//
//  ChatContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData

struct ChatContentView: View {
    @Environment(\.undoManager) var undoManager
    @Environment(\.modelContext) var modelContext
    @Environment(\.isSearching) private var isSearching
    @Environment(ChatVM.self) var chatVM
    
    @ObservedObject var config = AppConfig.shared
    
    @FocusState private var isSearchFieldFocused: FocusedField?
    
    var body: some View {
        @Bindable var chatVM = chatVM
        
        NavigationSplitView {
            if !chatVM.searchText.isEmpty && chatVM.searchTokens.contains(.messages) {
                MessageGroupList(searchText: chatVM.searchText)
                    .navigationSplitViewColumnWidth(min: 270, ideal: 300, max: 400)
            } else {
                ChatList(status: chatVM.statusFilter, searchText: chatVM.searchText, searchTokens: chatVM.searchTokens)
                    .navigationSplitViewColumnWidth(min: 270, ideal: 300, max: 400)
            }
        } detail: {
            if let chat = chatVM.activeChat {
                ChatDetail(chat: chat)
                    .id(chat.id)
            } else {
                Text("^[\(chatVM.selections.count) Chat](inflect: true) Selected")
                    .font(.title)
                    .fullScreenBackground()
            }
        }
        .onChange(of: undoManager, initial: true) {
            modelContext.undoManager = undoManager
        }
        .sheet(isPresented: .constant(!config.hasCompletedOnboarding)) {
            OnboardingView()
        }
        .searchable(text: $chatVM.localSearchText, tokens: $chatVM.searchTokens, placement: searchPlacement) { token in
            Text(token.name)
        }
        .searchSuggestions {
            ForEach(chatVM.filteredTokens) { suggestion in
                Text("Matching: \(suggestion.name)")
                    .searchCompletion(suggestion)
            }
        }
        .searchFocused($isSearchFieldFocused, equals: .searchBox)
        .onSubmit(of: .search) {
            if chatVM.searchTokens.isEmpty {
                chatVM.searchTokens = [.messages]
            }
            chatVM.searchText = chatVM.localSearchText
        }
        .onChange(of: chatVM.localSearchText) {
            if chatVM.localSearchText.isEmpty {
                chatVM.searchText = ""
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Search") {
                    isSearchFieldFocused = .searchBox
                }
                .keyboardShortcut("f")
            }
        }
    }
    
    private var searchPlacement: SearchFieldPlacement {
        #if os(macOS)
        return .sidebar
        #else
        return .automatic
        #endif
    }
}

#Preview {
    ChatContentView()
        .modelContainer(for: Chat.self, inMemory: true)
        .environment(ChatVM())
}
