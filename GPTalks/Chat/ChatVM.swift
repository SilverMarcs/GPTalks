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
        guard let chat = activeChat, !chat.isStreaming,
              let lastThread = chat.threads.last else { return nil }
        return (chat, lastThread)
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
        guard let (chat, _) = activeChatAndLastThread else { return }
        guard let lastUserThread = chat.threads.last(where: { $0.role == .user }) else { return }
        chat.inputManager.setupEditing(thread: lastUserThread)
    }
    
    // must provide new session, not the one to be forked
    func fork(newSession: Chat) {
        modelContext.insert(newSession)
        #if os(macOS)
        self.chatSelections = [newSession]
        #else
        self.chatSelections = []
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.chatSelections = [newSession]
        }
        #endif
    }
    
    @discardableResult
    func createNewSession(provider: Provider? = nil) -> Chat? {
        let config: ChatConfig
        
        if let providedProvider = provider {
            // Use the provided provider
            config = ChatConfig(provider: providedProvider, purpose: .chat)
        } else {
            // Use the default provider
            let fetchDefaults = FetchDescriptor<ProviderDefaults>()
            let defaults = try! modelContext.fetch(fetchDefaults)
            
            let defaultProvider = defaults.first!.defaultProvider
            
            config = ChatConfig(provider: defaultProvider, purpose: .chat)
        }
        
        let newItem = Chat(config: config)
        modelContext.insert(newItem)
        try? modelContext.save()
        
        self.searchText = ""
        self.chatSelections = [newItem]
        
        return newItem
    }
    
    // MARK: - Search
    var searchText: String = ""
    var hasFocus: Bool = false
    var searchResults: [MatchedSession] = []
    var searching: Bool = false
    
    private var searchTask: Task<Void, Never>?
    private let debounceInterval: TimeInterval = 0.5 // 500 milliseconds
    
    func debouncedSearch(chats: [Chat]) {
        searching = true
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
        guard !searchText.isEmpty else {
            searchResults = []
            searching = false
            return
        }
        
        let searchText = self.searchText
        searching = true
        
        let cleanedSearchText = cleanMarkdown(searchText)
        
        let results = await Task.detached(priority: .userInitiated) {
            chats.compactMap { chat in
                let matchingThreads = chat.unorderedThreads.compactMap { thread in
                    let content = thread.content
                    let cleanedContent = self.cleanMarkdown(content)
                    if cleanedContent.localizedCaseInsensitiveContains(cleanedSearchText) {
                        return MatchedThread(thread: thread, chat: chat)
                    }
                    return nil
                }
                return matchingThreads.isEmpty ? nil : MatchedSession(chat: chat, matchedThreads: matchingThreads)
            }
        }.value
        
        await MainActor.run {
            searchResults = results
            searching = false
        }
    }

    func cleanMarkdown(_ text: String) -> String {
        let markdownCharacters = CharacterSet(charactersIn: "#*_`!:.^")
        let cleanedText = text.components(separatedBy: markdownCharacters).joined()
        
        return cleanedText
    }
}
