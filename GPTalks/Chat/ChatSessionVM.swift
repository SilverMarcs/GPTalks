//
//  ChatSessionVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Observable class ChatSessionVM {
    var chatSelections: Set<ChatSession> = []
    var searchText: String = ""
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public var activeSession: ChatSession? {
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
        
        Task.detached {
            if let lastGroup = session.adjustedGroups.last {
                session.deleteConversationGroup(lastGroup)
            }
        }
    }
    
    func resetLastContext() {
        guard let session = activeSession, !session.isStreaming else { return }
        
        if let lastGroup = session.groups.last {
            session.resetContext(at: lastGroup)
        }
    }
    
    func editLastMessage() {
        guard let session = activeSession else { return }
        
        if let lastUserGroup = session.groups.last(where: { $0.role == .user }) {
            lastUserGroup.setupEditing()
        }
    }
    
    // must provide new session, not the one to be forked
    func fork(newSession: ChatSession) {
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
    func createNewSession(provider: Provider? = nil) -> ChatSession? {
        let config: SessionConfig
        
        if let providedProvider = provider {
            // Use the provided provider
            config = SessionConfig(provider: providedProvider, purpose: .chat)
        } else {
            // Use the default provider
            let fetchDefaults = FetchDescriptor<ProviderDefaults>()
            let defaults = try! modelContext.fetch(fetchDefaults)
            
            let defaultProvider = defaults.first!.defaultProvider
            
            config = SessionConfig(provider: defaultProvider, purpose: .chat)
        }
        
        let newItem = ChatSession(config: config)
        modelContext.insert(newItem)
        try? modelContext.save()
        
        self.chatSelections = [newItem]
        
        return newItem
    }
}
