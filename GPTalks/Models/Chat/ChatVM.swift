//
//  ChatVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Observable class ChatVM {
    // TODO: rename
    var chatSelections: Set<Chat> = []
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public var activeChat: Chat? {
        guard chatSelections.count == 1 else { return nil }
        return chatSelections.first
    }
    
    private var activeChatAndLastThread: (Chat, Thread)? {
        guard let chat = activeChat, !chat.isReplying,
              let lastThread = chat.threads.last else { return nil }
        return (chat, lastThread)
    }
    
    func sendPrompt() async {
        guard let chat = activeChat else { return }
        await chat.sendInput()
    }
    
    func stopStreaming() {
        activeChat?.stopStreaming()
    }
    
    func regenLastMessage() async {
        guard let (chat, lastThread) = activeChatAndLastThread else { return }
        await chat.regenerate(thread: lastThread)
    }
    
    func deleteLastMessage() {
        guard let (chat, lastThread) = activeChatAndLastThread else { return }
        chat.deleteThread(lastThread)
    }

    func editLastMessage() {
        guard let chat = activeChat else { return }
        guard let lastUserThread = chat.threads.last(where: { $0.role == .user }) else { return }
        chat.inputManager.setupEditing(thread: lastUserThread)
    }
    
    // must provide new session, not the one to be forked
    func fork(newChat: Chat) {
        modelContext.insert(newChat)
        #if os(macOS)
        self.chatSelections = [newChat]
        #else
        self.chatSelections = []
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.chatSelections = [newChat]
        }
        #endif
    }
    
    @discardableResult
    func createNewSession(provider: Provider? = nil, model: AIModel? = nil) -> Chat? {
        let provider = provider ?? DatabaseService.shared.getDefaultProvider()
        let config = ChatConfig(provider: provider, purpose: .chat)
        
        if let model = model {
            config.model = model
        }
        
        let newChat = Chat(config: config)
        modelContext.insert(newChat)
        
        searchText = ""
        chatSelections = [newChat]
        try? modelContext.save()
        
        return newChat
    }
    
    // MARK: - Search
    var searchText: String = ""
    var searchResults: [MatchedSession] = []
    var isSearching: Bool = false
    
    private var searchTask: Task<Void, Never>?
    private let debounceInterval: TimeInterval = 0.5 // 0.5sec
    
    func resetSearch() {
        searchText = ""
        searchResults = []
    }
    
    func debouncedSearch(chats: [Chat]) {
        if searchText.isEmpty {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        searchTask?.cancel()
        
        searchTask = Task {
            do {
                try await Task.sleep(for: .seconds(debounceInterval))
                if !Task.isCancelled {
                    await updateMatchingThreads(chats: chats)
                }
            } catch {
                print("Error debouncing search: \(error.localizedDescription)")
            }
        }
    }

    
    func updateMatchingThreads(chats: [Chat]) async {
        isSearching = true
        
        let results = await Task.detached(priority: .userInitiated) {
            chats.compactMap { chat in
                let matchingThreads = chat.unorderedThreads.compactMap { thread in
                    let content = thread.content
                    let cleanedContent = content.cleanMarkdown()
                    if cleanedContent.localizedCaseInsensitiveContains(self.searchText) {
                        return MatchedThread(thread: thread, chat: chat)
                    }
                    return nil
                }
                return matchingThreads.isEmpty ? nil : MatchedSession(chat: chat, matchedThreads: matchingThreads)
            }
        }.value
        
        await MainActor.run {
            searchResults = results
            isSearching = false
        }
    }
}
