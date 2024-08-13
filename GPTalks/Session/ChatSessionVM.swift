//
//  ChatSessionVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData
import Foundation

//MARK: Chat Session
extension SessionVM {
    public var activeSession: Session? {
        guard selections.count == 1 else { return nil }
        return selections.first
    }
    
    func sendMessage() {
        guard let session = activeSession else { return }
        Task { @MainActor in
            await session.sendInput()
        }
    }
    
    func regenLastMessage() {
        guard let session = activeSession, !session.isStreaming else { return }
        
        if let lastGroup = session.groups.last {
            if lastGroup.role == .user {
                lastGroup.setupEditing()
                Task { @MainActor in
                    await lastGroup.session?.sendInput()
                }
            } else if lastGroup.role == .assistant {
                Task { @MainActor in
                    session.regenerate(group: lastGroup)
                }
            }
        }
    }
    
    func deleteLastMessage() {
        guard let session = activeSession, !session.isStreaming else { return }
        
        if let lastGroup = session.groups.last {
            session.deleteConversationGroup(lastGroup)
        }
    }
    
    func resetLastContext() {
        guard let session = activeSession else { return }
        
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
    
    func fork(session: Session, sessions: [Session], modelContext: ModelContext) {
        withAnimation {
            for existingSession in sessions {
                existingSession.order += 1
            }
            
            session.order = 0
            modelContext.insert(session)
            self.selections = [session]
        }
        
        try? modelContext.save()
    }
    
    func addQuickItem(providers: [Provider], modelContext: ModelContext) -> Session {
        if let defaultQuickProvider = ProviderManager.shared.getQuickProvider(providers: providers) {
            let config = SessionConfig(provider: defaultQuickProvider, purpose: .quick)
            let session = Session(config: config)
            config.session = session
            session.isQuick = true
            
            return session
        }
        
        return Session(config: SessionConfig())
    }
}
