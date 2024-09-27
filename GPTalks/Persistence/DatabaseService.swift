//
//  DatabaseService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/31/24.
//

import Foundation
import SwiftData

// make modelactor
class DatabaseService {
    static var shared = DatabaseService()
    
    var container: ModelContainer = {
        let schema = Schema([
            ChatSession.self,
            SessionConfig.self,
            Conversation.self,
            ConversationGroup.self,
            Provider.self,
            AIModel.self,
            ImageSession.self,
            ImageGeneration.self,
            ImageConfig.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var modelContext: ModelContext
    
    init() {
        modelContext = ModelContext(container)
    }
    
    func createNewSession(provider: Provider? = nil) {
        let config: SessionConfig
        
        if let providedProvider = provider {
            config = SessionConfig(provider: providedProvider, purpose: .chat)
        } else {
            // Use the default provider
            let fetchProviders = FetchDescriptor<Provider>()
            let fetchedProviders = try! modelContext.fetch(fetchProviders)
            
            guard let defaultProvider = ProviderManager.shared.getDefault(providers: fetchedProviders) else {
                return
            }
            
            config = SessionConfig(provider: defaultProvider, purpose: .chat)
        }
        
        let newItem = ChatSession(config: config)
        
        var fetchSessions = FetchDescriptor<ChatSession>()
        fetchSessions.sortBy = [SortDescriptor(\.order)]
        let fetchedSessions = try! modelContext.fetch(fetchSessions)
        
        for session in fetchedSessions {
            session.order += 1
        }
        
        newItem.order = 0
        modelContext.insert(newItem)
    }
}
