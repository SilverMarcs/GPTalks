//
//  ChatCommands.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ChatCommands: Commands {
    @ObservedObject var config = AppConfig.shared
    @Environment(SessionVM.self) var sessionVM
    
    var body: some Commands {
        CommandMenu("Chat") {
            Button("Send Prompt") {
                sessionVM.sendMessage()
            }
            .keyboardShortcut(.return, modifiers: .command)
            
            Button("Stop Streaming") {
                sessionVM.stopStreaming()
            }
            .keyboardShortcut("d", modifiers: .command)
            .disabled(!(sessionVM.activeSession?.isReplying ?? true))
            
            Section {
                Button("Regen Last Message") {
                    Task { @MainActor in
                        await sessionVM.regenLastMessage()
                    }
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
