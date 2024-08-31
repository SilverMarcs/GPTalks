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
            .keyboardShortcut(.return, modifiers: commandModifier)
            
            Button("Stop Streaming") {
                sessionVM.stopStreaming()
            }
            .keyboardShortcut("d", modifiers: commandModifier)
            .disabled(!(sessionVM.activeSession?.isReplying ?? true))
            
            Section {
                Button("Regen Last Message") {
                    Task { @MainActor in
                        await sessionVM.regenLastMessage()
                    }
                }
                .keyboardShortcut("r", modifiers: commandModifier)
                
                Button("Edit Last Message") {
                    sessionVM.editLastMessage()
                }
                .keyboardShortcut("e", modifiers: commandModifier)
            }
            
            Section {
                Button("Delete Last Message") {
                    sessionVM.deleteLastMessage()
                }
                .keyboardShortcut(.delete, modifiers: commandModifier)
                
                Button("Reset Context") {
                    sessionVM.resetLastContext()
                }
                .keyboardShortcut("k", modifiers: commandModifier)
            }
        }
    }
    
    private var commandModifier: EventModifiers {
        #if targetEnvironment(macCatalyst)
        return [.command, .shift]
        #else
        return .command
        #endif
    }
}
