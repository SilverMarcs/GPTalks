//
//  PersistenceManager.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/9/24.
//

import Foundation
import SwiftData

@ModelActor
actor PersistenceManager {
    @MainActor
    static func create() -> ModelContainer {
        let schema = Schema([
            Session.self,
            Conversation.self,
            Provider.self,
            AIModel.self,
            ConversationGroup.self,
            SessionConfig.self,
            ImageSession.self,
            ImageGeneration.self,
            ImageConfig.self,
        ])
        
        let container = try! ModelContainer(for: schema)
//        container.mainContext.undoManager = UndoManager()
        
        var fetchProviders = FetchDescriptor<Provider>()
        fetchProviders.fetchLimit = 1
        
        guard try! container.mainContext.fetch(fetchProviders).count == 0 else {
            return container
        }
        
        // This code will only run if the persistent store is empty.
        let openAI = Provider.factory(type: .openai)
            openAI.order = 0
        let anthropic = Provider.factory(type: .anthropic)
            anthropic.order = 1
        let google = Provider.factory(type: .google)
            google.order = 2
        
        container.mainContext.insert(openAI)
        container.mainContext.insert(anthropic)
        container.mainContext.insert(google)
        
        return container
    }
}
