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
    
    func addItem(providerManager: ProviderManager, providers: [Provider], modelContext: ModelContext) {
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
            modelContext.insert(newItem)
            self.selections = [newItem]
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
