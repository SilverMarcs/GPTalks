//
//  MenuCommands.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData

struct MenuCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        SidebarCommands()
        
//        InspectorCommands()
        
//        TextEditingCommands()
        
//        TextFormattingCommands()
        
//        ToolbarCommands()
        
        CommandGroup(replacing: .appInfo) {
            Button("About GPTalks") {
                openWindow(id: "about")
            }
        }
        
        CommandGroup(replacing: .help) {
            Button("GPTalks Help") {
                openWindow(id: "help")
            }
        }
        
        CommandGroup(before: .appSettings) {
            Button("Settings") {
                openWindow(id: "settings")
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}
