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
    
    func stopStreaming() {
        guard let session = activeSession, session.isStreaming else { return }
        session.stopStreaming()
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
    
    func fork(session: Session, modelContext: ModelContext) {
        withAnimation {
            // Create a predicate to filter out sessions where isQuick is true
            let predicate = #Predicate<Session> { session in
                session.isQuick == false
            }
            
            // Create a FetchDescriptor with the predicate and sort descriptor
            let descriptor = FetchDescriptor<Session>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.order)]
            )
            
            // Fetch the sessions
            if let sessions = try? modelContext.fetch(descriptor) {
                // Update the order of existing sessions
                for existingSession in sessions {
                    existingSession.order += 1
                }
                
                // Insert the new session
                session.order = 0
                modelContext.insert(session)
                self.selections = [session]
            }
        }
        
        try? modelContext.save()
    }
    
    @discardableResult
    func createNewSession(modelContext: ModelContext) -> Session? {
        let fetchProviders = FetchDescriptor<Provider>()
        
        let fetchedProviders = try! modelContext.fetch(fetchProviders)
        
        if let provider = ProviderManager.shared.getDefault(providers: fetchedProviders) {
            let config = SessionConfig(provider: provider, purpose: .chat)
            let newItem = Session(config: config)
            config.session = newItem
            
            var fetchSessions = FetchDescriptor<Session>()
            fetchSessions.sortBy = [SortDescriptor(\.order)]
            let fetchedSessions = try! modelContext.fetch(fetchSessions)
            
            for session in fetchedSessions {
                session.order += 1
            }
            
            newItem.order = 0
            modelContext.insert(newItem)
            
            return newItem
        }
        
        return nil
    }
}
