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
        
//        ToolbarCommands()
        
        CommandGroup(replacing: CommandGroupPlacement.appInfo) {
            Button("About GPTalks") {
                openWindow(id: "about")
            }
        }
        
        CommandGroup(before: .appSettings) {
            Button("Settings") {
                OpenSettingsTip().invalidate(reason: .actionPerformed)
                openWindow(id: "settings")
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}
