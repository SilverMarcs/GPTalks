//
//  ChatContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

#if os(macOS)
import SwiftUI
import SwiftData

struct ChatContentView: View {
    @Environment(\.undoManager) var undoManager
    @Environment(\.modelContext) var modelContext
    @Environment(\.isSearching) private var isSearching
    @Environment(ChatVM.self) var chatVM
    
    @ObservedObject var config = AppConfig.shared
    
    @State private var localSearchText = ""
    @FocusState private var isSearchFieldFocused: FocusedField?
    
    var body: some View {
        @Bindable var chatVM = chatVM
        
        NavigationSplitView {
            ChatList(status: chatVM.statusFilter, searchText: chatVM.searchText, searchTokens: chatVM.serchTokens)
                .navigationSplitViewColumnWidth(min: 270, ideal: 300, max: 400)
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
        .searchable(text: $localSearchText, tokens: $chatVM.serchTokens, placement: searchPlacement) { token in
            Text(token.name)
        }
        .searchSuggestions {
            ForEach(filteredTokens) { suggestion in
                Text("Matching: \(suggestion.name)")
                    .searchCompletion(suggestion)
            }
        }
        .searchFocused($isSearchFieldFocused, equals: .searchBox)
        .onSubmit(of: .search) {
            chatVM.searchText = localSearchText
        }
        .onChange(of: localSearchText) {
            if localSearchText.isEmpty {
                chatVM.searchText = ""
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Search") {
                    isSearchFieldFocused = .searchBox
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
            }
        }
    }
    
    var filteredTokens: [ChatSearchToken] {
        let remainingTokens = ChatSearchToken.allCases.filter { !chatVM.serchTokens.contains($0) }
        return localSearchText.isEmpty
            ? remainingTokens
            : remainingTokens.filter { $0.name.lowercased().hasPrefix(localSearchText.lowercased()) }
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
#endif
