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
            WindowGroup(id: "main") {
                ContentView()
                #if os(macOS)
                    .windowDetector(isMainWindowActive: $isMainWindowActive)
                #endif
            }
            .commands {
                MenuCommands(isMainWindowActive: $isMainWindowActive)
            }
            
            #if os(macOS)
            SettingsWindow()
            
            QuickPanelWindow()
            #endif
        }
        .environment(sessionVM)
        .modelContainer(for: models, isUndoEnabled: true)
    }
    
    let models: [any PersistentModel.Type] =
        [
           Session.self,
           Folder.self,
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
