//
//  SessonVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Observable class SessionVM {
    var selections: Set<Session> = []
    var selection: Session?
    var searchText: String = ""
    
    var chatCount: Int = 12
    
    func addItem(sessions: [Session], providerManager: ProviderManager, providers: [Provider], modelContext: ModelContext) {
        let provider: Provider
        if let defaultProvider = providerManager.getDefault(providers: providers) {
            provider = defaultProvider
        } else if let firstProvider = providers.first {
            provider = firstProvider
        } else {
            return
        }
        
        let config = SessionConfig(
            provider: provider, model: provider.chatModel)
        
        let newItem = Session(config: config)
        
        withAnimation {
            // Increment the order of all existing items
            for session in sessions {
                session.order += 1
            }
            
            newItem.order = 0  // Set the new item's order to 0 (top of the list)
            modelContext.insert(newItem)
            self.selections = [newItem]
        }
        
        try? modelContext.save()
    }
    
    func fork(session: Session, sessions: [Session], providerManager: ProviderManager, providers: [Provider], modelContext: ModelContext) {
        withAnimation {
            // Increment the order of all existing items
            for existingSession in sessions {
                existingSession.order += 1
            }
            
            session.order = 0  // Set the forked session's order to 0 (top of the list)
            modelContext.insert(session)
            self.selections = [session]
        }
        
        try? modelContext.save()
    }
    
    func addQuickItem(providerManager: ProviderManager, providers: [Provider], modelContext: ModelContext) -> Session {
        if let defaultProvider = providerManager.getDefault(providers: providers) {
            let provider = defaultProvider
            let config = SessionConfig(provider: provider, model: provider.quickChatModel)
            let session = Session(config: config)
            session.isQuick = true
            
            return session
        }
        
        return Session()
    }
}
