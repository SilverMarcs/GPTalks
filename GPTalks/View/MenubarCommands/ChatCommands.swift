//
//  ChatCommands.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ChatCommands: Commands {
    @ObservedObject var config = AppConfig.shared
    let sessionVM: SessionVM
    
    var body: some Commands {
        CommandMenu("Chat") {
            Button("Send Prompt") {
                sessionVM.sendMessage()
            }
            .keyboardShortcut(.return, modifiers: .command)
            
            Section {
                Button("Regen Last Message") {
                    sessionVM.regenLastMessage()
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Button("Edit Last Message") {
                    sessionVM.editLastMessage()
                }
                .keyboardShortcut("e", modifiers: .command)
            }
            
            Section {
                Button("Delete Last Message") {
                    sessionVM.deleteLastMessage()
                }
                .keyboardShortcut(.delete, modifiers: .command)
                
                Button("Reset Context") {
                    sessionVM.resetLastContext()
                }
                .keyboardShortcut("k", modifiers: .command)
            }
        }
    }
}
