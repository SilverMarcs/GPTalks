//
//  DatabaseService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/31/24.
//

import SwiftUI
import Foundation
import SwiftData
#if os(macOS)
import KeyboardShortcuts
#endif
import Observation

// make modelactor

@MainActor
final class DatabaseService: NSObject {
    
    static let shared = DatabaseService()
    
    let container: ModelContainer = {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
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
    
    var modelContext: ModelContext {
        container.mainContext
    }
    
    func getDefaultProvider() -> Provider {
        let fetchDefaults = FetchDescriptor<ProviderDefaults>()
        let defaults = try! modelContext.fetch(fetchDefaults)
        return defaults.first!.defaultProvider
    }
    
    func initialSetup(modelContext: ModelContext) {
        // Reset the quick session on app launch
        var fetchQuickSession = FetchDescriptor<Chat>()
        let quickId = ChatStatus.quick.id
        fetchQuickSession.predicate = #Predicate { $0.statusId == quickId }
        fetchQuickSession.fetchLimit = 1
        
        if let quickSession = try? modelContext.fetch(fetchQuickSession).first {
            quickSession.deleteAllThreads()
        }
        
        var fetchProviders = FetchDescriptor<Provider>()
        fetchProviders.fetchLimit = 1
        
        // -- Upto here runs on every app launch -- //
        
        // If there are already providers in the modelContext, return since the setup has already been done
        guard try! modelContext.fetch(fetchProviders).count == 0 else { return }
        
        #if os(macOS)
        KeyboardShortcuts.setShortcut(.init(.space, modifiers: .option), for: .togglePanel) // TODO: very bad (visibility wise) place to do this.
        #endif
        
        // adding default providers
        let openAI = Provider.factory(type: .openai)
        openAI.isPersistent = true
        let anthropic = Provider.factory(type: .anthropic)
        anthropic.isPersistent = true
        let google = Provider.factory(type: .google)
        google.isPersistent = true
        
        modelContext.insert(openAI)
        modelContext.insert(anthropic)
        modelContext.insert(google)
        
        // quick chat
        let config = ChatConfig(provider: openAI, purpose: .quick)
        let session = Chat(config: config)
        session.status = .quick
        session.statusId = ChatStatus.quick.id
        session.title = "(↯) Quick Session"
        modelContext.insert(session)
        
        // demo chat with some threads
        let normalChatConfig = ChatConfig(provider: openAI, purpose: .chat)
        let normalSession = Chat(config: normalChatConfig)
        normalSession.addThread(.mockUserThread)
        normalSession.addThread(.mockAssistantThread)
        modelContext.insert(normalSession)
        
        // demo favourite chat
        let normalChatConfig2 = ChatConfig(provider: openAI, purpose: .chat)
        let favouriteSession = Chat(config: normalChatConfig2)
        favouriteSession.status = .starred
        favouriteSession.statusId = ChatStatus.starred.id
        favouriteSession.title = "Favourite Chat"
        modelContext.insert(favouriteSession)
        
        // archivd chat
        let normalChatConfig3 = ChatConfig(provider: openAI, purpose: .chat)
        let archivedSession = Chat(config: normalChatConfig3)
        archivedSession.status = .archived
        archivedSession.statusId = ChatStatus.archived.id
        archivedSession.title = "Archived Chat"
        modelContext.insert(archivedSession)
        
        // image session
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
