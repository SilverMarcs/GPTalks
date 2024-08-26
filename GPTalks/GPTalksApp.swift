//
//  GPTalksApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData
import TipKit
import KeyboardShortcuts

@main
struct GPTalksApp: App {
    @State private var sessionVM = SessionVM()

    var body: some Scene {
        Group {
            MainWindow()
            
            #if os(macOS)
            SettingsWindow()
            
            QuickPanelWindow()
            #endif
        }
        .environment(sessionVM)
        .modelContainer(for: models, isUndoEnabled: true)
    }
    
    #if os(macOS)
    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
        AppConfig.shared.hideDock = false
    }
    #endif
    
    let models: [any PersistentModel.Type] = [
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
