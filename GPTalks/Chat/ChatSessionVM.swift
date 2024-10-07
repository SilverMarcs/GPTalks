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
        await session.sendInput()
    }
    
    func handlePaste() {
        guard let session = activeSession else { return }
        session.inputManager.handlePaste(supportedFileTypes: session.config.provider.type.supportedFileTypes)
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
    
    
    #warning("this may not work")
    func fork(session: ChatSession) {
        withAnimation {
            // Create a predicate to filter out sessions where isQuick is true
            let predicate = #Predicate<ChatSession> { session in
                session.isQuick == false
            }
            
            // Create a FetchDescriptor with the predicate and sort descriptor
            let descriptor = FetchDescriptor<ChatSession>(
                predicate: predicate
            )
            
            // Fetch the sessions
            if let sessions = try? modelContext.fetch(descriptor) {
                modelContext.insert(session)
                #if os(macOS)
                self.chatSelections = [session]
                #else
                self.chatSelections = []
                #endif
            }
        }
        
        try? modelContext.save()
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
        try? modelContext.save()
        
        modelContext.insert(newItem)
        
        chatSelections = [newItem]
        
        return newItem
    }
    
    var state: ListState = .chats
    
    enum ListState: String, CaseIterable {
        case chats
        case images
    }
}
