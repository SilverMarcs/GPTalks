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
    @State private var chatVM = ChatSessionVM(modelContext: DatabaseService.shared.container.mainContext)
    @State private var imageVM = ImageSessionVM(modelContext: DatabaseService.shared.container.mainContext)
    
    var body: some Scene {
        Group {
            ChatWindow()
            
            #if os(macOS)
            ImageWindow()
            
            SettingsWindow()
            
            QuickPanelWindow()
            #endif
        }
        .commands {
            MenuCommands()
        }
        .environment(chatVM)
        .environment(imageVM)
        .modelContainer(DatabaseService.shared.container)
    }
    
    #if os(macOS)
    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
        AppConfig.shared.hideDock = false
    }
    #endif
}
