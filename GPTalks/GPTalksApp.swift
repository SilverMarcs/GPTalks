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
        .modelContainer(DatabaseService.shared.container)
    }
    
    #if os(macOS)
    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
        AppConfig.shared.hideDock = false
    }
    #endif
}
