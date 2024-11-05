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
            Chat.self,
            ChatConfig.self,
            Thread.self,
            Provider.self,
            AIModel.self,
            ImageGeneration.self,
            ImageConfig.self,
            ProviderDefaults.self,
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
        var fetchQuickSession = FetchDescriptor<Chat>()
        fetchQuickSession.predicate = #Predicate { $0.isQuick == true }
        fetchQuickSession.fetchLimit = 1
        
        if let quickSession = try? modelContext.fetch(fetchQuickSession).first {
            quickSession.deleteAllThreads()
        }
        
        var fetchProviders = FetchDescriptor<Provider>()
        fetchProviders.fetchLimit = 1
        
        // If there are already providers in the modelContext, return since the setup has already been done
        guard try! modelContext.fetch(fetchProviders).count == 0 else { return }
        
        let openAI = Provider.factory(type: .openai)
        openAI.isPersistent = true
        let anthropic = Provider.factory(type: .anthropic)
        anthropic.isPersistent = true
        let google = Provider.factory(type: .google)
        google.isPersistent = true
        
        modelContext.insert(openAI)
        modelContext.insert(anthropic)
        modelContext.insert(google)
        
        let config = ChatConfig(provider: openAI, purpose: .quick)
        let session = Chat(config: config)
        session.isQuick = true
        session.title = "(↯) Quick Session"
        modelContext.insert(session)
        
        let normalChatConfig = ChatConfig(provider: openAI, purpose: .chat)
        let normalSession = Chat(config: normalChatConfig)
        modelContext.insert(normalSession)
        
        let imageChatConfig = ImageConfig(prompt: "", provider: openAI)
        let imageSession = ImageSession(config: imageChatConfig)
        modelContext.insert(imageSession)
        
        let providerDefaults = ProviderDefaults(defaultProvider: openAI,
                                                quickProvider: openAI,
                                                imageProvider: openAI,
                                                toolImageProvider: openAI,
                                                toolSTTProvider: openAI)
        modelContext.insert(providerDefaults)
    }
}
