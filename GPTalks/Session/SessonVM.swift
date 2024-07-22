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
    var providerManager: ProviderManager
    
    init(providerManager: ProviderManager = ProviderManager.shared) {
        self.providerManager = providerManager
    }
    
    var selections: Set<Session> = []
    var imageSelections: Set<ImageSession> = []
    
    var searchText: String = ""
    
    var state: ListState = .chats
    
    #if os(macOS)
    var chatCount: Int = 12
    #else
    var chatCount: Int = .max
    #endif
    
    func addimageSession(imageSessions: [ImageSession], providers: [Provider], modelContext: ModelContext) {
        let provider: Provider
        if let defaultProvider = providerManager.getDefault(providers: providers) {
            provider = defaultProvider
        } else if let firstProvider = providers.first {
            provider = firstProvider
        } else {
            return
        }
        
        let newItem = ImageSession(config: ImageConfig(provider: provider, model: provider.imageModel))
        
        withAnimation {
            // Increment the order of all existing items
            for session in imageSessions {
                session.order += 1
            }
            
            newItem.order = 0  // Set the new item's order to 0 (top of the list)
            modelContext.insert(newItem)
            self.imageSelections = [newItem]
        }
        
        try? modelContext.save()
    }
    
    func addItem(sessions: [Session], providers: [Provider], modelContext: ModelContext) {
        let provider: Provider
        if let defaultProvider = providerManager.getDefault(providers: providers) {
            provider = defaultProvider
        } else if let firstProvider = providers.first {
            provider = firstProvider
        } else {
            return
        }
        
        let config = SessionConfig(
            provider: provider)
        
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
        if let defaultQuickProvider = providerManager.getQuickProvider(providers: providers) {
            let config = SessionConfig(provider: defaultQuickProvider, isQuick: true)
            let session = Session(config: config)
            session.isQuick = true
            
            return session
        }
        
        return Session(config: SessionConfig())
    }
}

enum ListState: String {
    case chats
    case images
}
