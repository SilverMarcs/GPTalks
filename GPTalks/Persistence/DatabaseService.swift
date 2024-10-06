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
    
    func initialSetup(modelContext: ModelContext) {
        // Fetch the quick session from the modelContext
        var fetchQuickSession = FetchDescriptor<ChatSession>()
        fetchQuickSession.predicate = #Predicate { $0.isQuick == true }
        fetchQuickSession.fetchLimit = 1
        
        if let quickSession = try? modelContext.fetch(fetchQuickSession).first {
            quickSession.deleteAllConversations()
        }
        
        var fetchProviders = FetchDescriptor<Provider>()
        fetchProviders.fetchLimit = 1
        
        // If there are already providers in the modelContext, return since the setup has already been done
        guard try! modelContext.fetch(fetchProviders).count == 0 else { return }
        
        let openAI = Provider.factory(type: .openai)
        openAI.order = 0
        openAI.isPersistent = true
        let anthropic = Provider.factory(type: .anthropic)
        anthropic.order = 1
        anthropic.isPersistent = true
        let google = Provider.factory(type: .google)
        google.order = 2
        google.isPersistent = true
        
        modelContext.insert(openAI)
        modelContext.insert(anthropic)
        modelContext.insert(google)
        
        let config = SessionConfig(provider: openAI, purpose: .quick)
        let session = ChatSession(config: config)
        session.isQuick = true
        session.title = "(↯) Quick Session"
        
        modelContext.insert(session)
        
        ProviderManager.shared.defaultProvider = openAI.id.uuidString
        ProviderManager.shared.quickProvider = openAI.id.uuidString
        ProviderManager.shared.imageProvider = openAI.id.uuidString
        ProviderManager.shared.toolImageProvider = openAI.id.uuidString
    }
}
