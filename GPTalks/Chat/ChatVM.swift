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
    var chatSelections: Set<Chat> = []
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public var activeSession: Chat? {
        guard chatSelections.count == 1 else { return nil }
        return chatSelections.first
    }
    
    func sendMessage() async {
        guard let session = activeSession else { return }
        guard !session.isQuick else { return }
        await session.sendInput()
    }
    
    func stopStreaming() async {
        guard let session = activeSession, session.isStreaming else { return }
        await session.stopStreaming()
    }
    
    func regenLastMessage() async {
        guard let session = activeSession, !session.isStreaming else { return }
        
        if let lastGroup = session.groups.last {
            if lastGroup.role == .user {
                lastGroup.setupEditing()
                await lastGroup.session?.sendInput()
            } else if lastGroup.role == .assistant {
                await session.regenerate(group: lastGroup)
            }
        }
    }
    
    func deleteLastMessage() {
        guard let session = activeSession, !session.isStreaming else { return }
        
        if let lastGroup = session.groups.last {
            session.deleteThreadGroup(lastGroup)
        }
    }

    func editLastMessage() {
        guard let session = activeSession else { return }
        
        if let lastUserGroup = session.groups.last(where: { $0.role == .user }) {
            lastUserGroup.setupEditing()
        }
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
    
    func debouncedSearch(sessions: [Chat]) {
        searching = true
        searchTask?.cancel()
        
        searchTask = Task {
            do {
                try await Task.sleep(for: .seconds(debounceInterval))
                if !Task.isCancelled {
                    await updateMatchingThreads(sessions: sessions)
                }
            } catch {
                print("Error debouncing search: \(error.localizedDescription)")
            }
        }
    }

    
    func updateMatchingThreads(sessions: [Chat]) async {
        guard !searchText.isEmpty else {
            searchResults = []
            searching = false
            return
        }
        
        let searchText = self.searchText
        searching = true
        
        let cleanedSearchText = cleanMarkdown(searchText)
        
        let results = await Task.detached(priority: .userInitiated) {
            sessions.compactMap { session in
                let matchingThreads = session.unorderedGroups.compactMap { group in
                    let content = group.activeThread.content
                    let cleanedContent = self.cleanMarkdown(content)
                    if cleanedContent.localizedCaseInsensitiveContains(cleanedSearchText) {
                        return MatchedThread(conversation: group.activeThread, session: session)
                    }
                    return nil
                }
                return matchingThreads.isEmpty ? nil : MatchedSession(session: session, matchedThreads: matchingThreads)
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
