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
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

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
        setupShortcut()
        AppConfig.shared.hideDock = false
    }
    
    private func setupShortcut() {
        KeyboardShortcuts.onKeyDown(for: .togglePanel) {
            if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "quick" }) {
                if window.isVisible {
                    dismissWindow(id: "quick")
                } else {
                    openWindow(id: "quick")
                    window.makeKeyAndOrderFront(nil)
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
            } else {
                openWindow(id: "quick")
                if let newWindow = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "quick" }) {
                    newWindow.makeKeyAndOrderFront(nil)
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
            }
        }
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
