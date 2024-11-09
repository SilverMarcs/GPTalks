//
//  DatabaseService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/31/24.
//

import Foundation
import SwiftData
#if os(macOS)
import KeyboardShortcuts
#endif

// make modelactor
class DatabaseService {
    static var shared = DatabaseService()
    
    var container: ModelContainer = {
        let schema = Schema([
            Chat.self,
            ChatConfig.self,
            Thread.self,
            Provider.self,
            Generation.self,
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
    
    func getDefaultProvider() -> Provider {
        let fetchDefaults = FetchDescriptor<ProviderDefaults>()
        let defaults = try! modelContext.fetch(fetchDefaults)
        return defaults.first!.defaultProvider
    }
    
    func initialSetup(modelContext: ModelContext) {
        // Fetch the quick session from the modelContext
        var fetchQuickSession = FetchDescriptor<Chat>()
        let quickId = ChatStatus.quick.id
        fetchQuickSession.predicate = #Predicate { $0.statusId == quickId }
        fetchQuickSession.fetchLimit = 1
        
        if let quickSession = try? modelContext.fetch(fetchQuickSession).first {
            quickSession.deleteAllThreads()
        }
        
        var fetchProviders = FetchDescriptor<Provider>()
        fetchProviders.fetchLimit = 1
        
        // If there are already providers in the modelContext, return since the setup has already been done
        guard try! modelContext.fetch(fetchProviders).count == 0 else { return }
        
        #if os(macOS)
        KeyboardShortcuts.setShortcut(.init(.space, modifiers: .option), for: .togglePanel) // TODO: very bad (visibility wise) place to do this. 
        #endif
        
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
        session.status = .quick
        session.statusId = ChatStatus.quick.id
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
                                                sttProvider: openAI)
        modelContext.insert(providerDefaults)
    }
}
