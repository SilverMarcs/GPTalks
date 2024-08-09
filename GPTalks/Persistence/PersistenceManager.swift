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
        
        // fetch provider named "OpenAI
        //        var fetchOpenAI = FetchDescriptor<Provider>(
        //            predicate: #Predicate { $0.name == "OpenAI" }
        //        )
        //        fetchOpenAI.fetchLimit = 1
        //
        //        do {
        //            let fetch = try container.mainContext.fetch(fetchOpenAI)
        //            let openAI = fetch.first!
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            if ProviderManager.shared.defaultProvider == nil {
//                ProviderManager.shared.defaultProvider = openAI.id.uuidString
//            }
//
//            if ProviderManager.shared.quickProvider == nil {
//                ProviderManager.shared.quickProvider = openAI.id.uuidString
//            }
//        }
//
//        } catch {
//            print("Failed to fetch OpenAI provider: \(error)")
//        }

        return container
    }
}
