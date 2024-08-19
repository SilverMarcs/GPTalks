//
//  GPTalksApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct GPTalksApp: App {
    @State private var sessionVM = SessionVM()
    @FocusState var isMainWindowFocused

    var body: some Scene {
        Group {
            WindowGroup(id: "main") {
                ContentView()
                    .focusable()
                    .focused($isMainWindowFocused)
                    .task {
                        try? Tips.configure([.datastoreLocation(.applicationDefault)])
                    }
            }
            .commands {
                MenuCommands(isMainWindowFocused: _isMainWindowFocused)
            }
            
            #if os(macOS)
            SettingsWindow()
            
            QuickPanelWindow()
            #endif
        }
        .environment(sessionVM)
        .modelContainer(for: models, isUndoEnabled: true)
    }
    
    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
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
