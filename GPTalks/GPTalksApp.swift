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
    @State private var isMainWindowActive = true
//    @State var container = PersistenceManager.create()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionVM)
            #if os(macOS)
                .windowDetector(isMainWindowActive: $isMainWindowActive)
            #endif
        }

//        .modelContainer(container)
        .modelContainer(for: models, isUndoEnabled: true)
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
        .modelContainer(for: models, isUndoEnabled: true)
        #endif
    }
    
    let models: [any PersistentModel.Type] =
        [
           Session.self,
           Conversation.self,
           Provider.self,
           AIModel.self,
           ConversationGroup.self,
           SessionConfig.self,
           ImageSession.self,
           ImageGeneration.self,
           ImageConfig.self
        ]
}
