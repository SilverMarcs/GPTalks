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
    @State private var isMainWindowActive = true

    var body: some Scene {
        Group {
            WindowGroup {
                ContentView()
                #if os(macOS)
                    .windowDetector(isMainWindowActive: $isMainWindowActive)
                #endif
            }
            .commands {
                MenuCommands(isMainWindowActive: $isMainWindowActive)
            }
            
            #if os(macOS)
            Window("Settings", id: "settings") {
                SettingsView()
                    .frame(minWidth: 820, maxWidth: 820, minHeight: 570, maxHeight: 570)
            }
            .restorationBehavior(.disabled)
            .windowResizability(.contentSize)
            #endif
        }
        .environment(sessionVM)
        .modelContainer(for: models, isUndoEnabled: true)
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
