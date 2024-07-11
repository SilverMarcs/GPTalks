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
            Model.self,
            ConversationGroup.self,
            SessionConfig.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
