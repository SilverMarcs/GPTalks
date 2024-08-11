//
//  MenuCommands.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct MenuCommands: Commands {
    @Environment(\.openWindow) private var openWindow
    @Environment(SessionVM.self) var sessionVM
    @Binding var isMainWindowActive: Bool

    var body: some Commands {
        SidebarCommands()
        
        InspectorCommands()
        
        if isMainWindowActive {
            switch sessionVM.state {
            case .chats:
                ChatCommands(sessionVM: sessionVM)
            case .images:
                ImageCommands(sessionVM: sessionVM)
            }
        }
        
        CommandGroup(replacing: CommandGroupPlacement.newItem) {
        }
        
        CommandGroup(before: .appSettings) {
            Button("Settings") {
                openWindow(id: "settings")
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}
