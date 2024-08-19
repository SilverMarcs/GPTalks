//
//  MenuCommands.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData

struct MenuCommands: Commands {
    @Environment(\.modelContext) var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(SessionVM.self) var sessionVM
    @FocusState var isMainWindowFocused: Bool

    var body: some Commands {
        SidebarCommands()
        
//        InspectorCommands()
        
        if isMainWindowFocused {
            switch sessionVM.state {
            case .chats:
                ChatCommands(sessionVM: sessionVM)
            case .images:
                ImageCommands(sessionVM: sessionVM)
            }
        }
        
        CommandGroup(before: .appSettings) {
            Button("Settings") {
                openWindow(id: "settings")
            }
            .keyboardShortcut(",", modifiers: .command)
        }
        
        CommandGroup(replacing: .newItem) {
            Button("New Session") {
                sessionVM.createNewSession(modelContext: modelContext)
            }
            .keyboardShortcut("n")
        }
    }
}
