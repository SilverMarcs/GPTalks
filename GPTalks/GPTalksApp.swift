//
//  GPTalksApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData

@main
struct GPTalksApp: App {
    @State private var sessionVM = SessionVM()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionVM)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            InspectorCommands()
            
            MenuCommands(sessionVM: sessionVM)
        }

        #if os(macOS)
        Settings {
            SettingsView()
        }
        .modelContainer(sharedModelContainer)
        #endif
    }
    
    var sharedModelContainer: ModelContainer = {
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
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}


extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}

func isPadOS() -> Bool {
    #if os(macOS)
    return false
    #else
    return UIDevice.current.userInterfaceIdiom == .pad
    #endif
}
