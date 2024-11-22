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
    
    // must provide new chat, not the one to be forked
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
    
    // MARK: - Search
    var searchText: String = ""
    var serchTokens = [ChatSearchToken]()
    
    // MARK: - Quick Panel
    var isQuickPanelPresented: Bool = false
}
