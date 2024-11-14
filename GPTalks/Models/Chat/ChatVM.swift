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
    func createNewSession(provider: Provider? = nil, model: AIModel? = nil) async -> Chat? {
        let modelContext = DatabaseService.shared.modelContext
        
        let provider = provider ?? DatabaseService.shared.getDefaultProvider()
        let config = ChatConfig(provider: provider, purpose: .chat)
        
        if let model = model {
            NewChatTip().invalidate(reason: .actionPerformed)
            config.model = model
        }
        
        let newChat = Chat(config: config)
        modelContext.insert(newChat)
        
        searchText = ""
        selections = [newChat]
//        try? modelContext.save()
        
        return newChat
    }
    
    // MARK: - Search
    var searchText: String = ""
    
    // MARK: - Quick Panel
    var isQuickPanelPresented: Bool = false
}
