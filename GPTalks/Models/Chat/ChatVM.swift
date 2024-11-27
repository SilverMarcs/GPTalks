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
    var selections: Set<Chat> = []
    
    var statusFilter: ChatStatus = .normal
    
    public var activeChat: Chat? {
        guard selections.count == 1 else { return nil }
        return selections.first
    }
    
    @MainActor
    func fork(newChat: Chat) {
        let modelContext = DatabaseService.shared.modelContext
        modelContext.insert(newChat)
        #if os(macOS)
        self.selections = [newChat]
        #else
        self.selections = []
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selections = [newChat]
        }
        #endif
    }
    
    @MainActor
    @discardableResult
    func createNewChat(provider: Provider? = nil, model: AIModel? = nil) async -> Chat {
        let modelContext = DatabaseService.shared.modelContext
        
        let provider = provider ?? DatabaseService.shared.getDefaultProvider()
        let config = ChatConfig(provider: provider, purpose: .chat)
        
        if let model = model {
            config.model = model
        }
        
        let newChat = Chat(config: config)
        modelContext.insert(newChat)
        
        searchText = ""
        selections = [newChat]
        
        return newChat
    }
    
    // MARK: - Navigation
    func goToNextChat(chats: [Chat]) {
        guard let activeChat = activeChat,
              let index = chats.firstIndex(of: activeChat),
              index < chats.count - 1 else { return }
        
        let nextChat = chats[index + 1]
        selections = [nextChat]
    }

    func goToPreviousChat(chats: [Chat]) {
        guard let activeChat = activeChat,
              let index = chats.firstIndex(of: activeChat),
              index > 0 else { return }
        
        let previousChat = chats[index - 1]
        selections = [previousChat]
    }
    
    // MARK: - Search
    var searchText: String = ""
    var localSearchText: String = ""
    var serchTokens = [ChatSearchToken]()
    
    var filteredTokens: [ChatSearchToken] {
        let remainingTokens = ChatSearchToken.allCases.filter { !serchTokens.contains($0) }
        return localSearchText.isEmpty
            ? remainingTokens
            : remainingTokens.filter { $0.name.lowercased().hasPrefix(localSearchText.lowercased()) }
    }
    
    // MARK: - Quick Panel
    var isQuickPanelPresented: Bool = false
}
