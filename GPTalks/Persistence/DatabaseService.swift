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
            Message.self,
            Provider.self,
            Generation.self,
            ImageConfig.self,
            ProviderDefaults.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let modelContext = container.mainContext
            
            var fetchQuickChats = FetchDescriptor<Chat>()
            let quickId = ChatStatus.quick.id
            fetchQuickChats.predicate = #Predicate { $0.statusId == quickId }
            fetchQuickChats.fetchLimit = 1
            
            if let quickChat = try? modelContext.fetch(fetchQuickChats).first {
                quickChat.deleteAllMessages()
            }
            
            var fetchProviders = FetchDescriptor<Provider>()
            fetchProviders.fetchLimit = 1
            
            // Check if providers already exist
            if try modelContext.fetch(fetchProviders).count > 0 {
                return container // Return the container if setup is already done
            }
            
            #if os(macOS)
            KeyboardShortcuts.setShortcut(.init(.space, modifiers: .option), for: .togglePanel)
            #endif
            
            // Adding default providers
            let openAI = Provider.factory(type: .openai)
            openAI.isPersistent = true
            let anthropic = Provider.factory(type: .anthropic)
            anthropic.isPersistent = true
            let google = Provider.factory(type: .google)
            google.isPersistent = true
            
            modelContext.insert(openAI)
            modelContext.insert(anthropic)
            modelContext.insert(google)
            
            // Quick chat
            let config = ChatConfig(provider: openAI, purpose: .quick)
            let chat = Chat(config: config)
            chat.status = .quick
            chat.statusId = ChatStatus.quick.id
            chat.title = "(↯) Quick Chat"
            modelContext.insert(chat)
            
            // Demo favourite chat with some messages
            let normalChatConfig2 = ChatConfig(provider: openAI, purpose: .chat)
            let favouriteChat = Chat(config: normalChatConfig2)
            favouriteChat.status = .starred
            favouriteChat.statusId = ChatStatus.starred.id
            favouriteChat.addMessage(.mockUserMessage)
            favouriteChat.messages.append(.mockAssistantMessage)
            favouriteChat.title = "Favourite Chat"
            modelContext.insert(favouriteChat)
            
            // Demo chat with no messages
            let normalChatConfig = ChatConfig(provider: openAI, purpose: .chat)
            let normalChat = Chat(config: normalChatConfig)
            normalChat.totalTokens = 181
            modelContext.insert(normalChat)

            // Archived chat
            let normalChatConfig3 = ChatConfig(provider: openAI, purpose: .chat)
            let archivedChat = Chat(config: normalChatConfig3)
            archivedChat.status = .archived
            archivedChat.statusId = ChatStatus.archived.id
            archivedChat.title = "Archived Chat"
            modelContext.insert(archivedChat)
            
            // Image session
            let imageChatConfig = ImageConfig(prompt: "", provider: openAI)
            let imageSession = ImageSession(config: imageChatConfig)
            modelContext.insert(imageSession)
            
            let providerDefaults = ProviderDefaults(defaultProvider: openAI,
                                                    quickProvider: openAI,
                                                    imageProvider: openAI,
                                                    sttProvider: openAI)
            modelContext.insert(providerDefaults)
            
            return container
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
}
