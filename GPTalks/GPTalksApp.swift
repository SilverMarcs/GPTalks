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
    @Environment(\.openWindow) private var openWindow
    @State private var sessionVM = SessionVM()
    @State private var isMainWindowActive = false
    @State var container = PersistenceManager.create()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionVM)
            #if os(macOS)
                .windowDetector(isMainWindowActive: $isMainWindowActive)
            #endif
        }
//        .modelContainer(sharedModelContainer)
        .modelContainer(container)
        .commands {
            InspectorCommands()
            
            if isMainWindowActive {
                MenuCommands(sessionVM: sessionVM)
            }
            
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
            }
            
            CommandGroup(before: .appSettings) {
                Button("Settings") {
                    openWindow(id: "settings")
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }

        #if os(macOS)
        Window("Settings", id: "settings") {
            SettingsView()
        }
//        .restorationBehavior(.disabled)
//        .modelContainer(sharedModelContainer)
        .modelContainer(container)
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
