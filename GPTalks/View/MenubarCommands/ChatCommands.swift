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
                Task { @MainActor in
                    await sessionVM.sendMessage()
                }
            }
            .keyboardShortcut(.return, modifiers: commandModifier)
            
            Button("Paste Files") {
                sessionVM.handlePaste()
            }
            .keyboardShortcut("b")
            
            Button("Stop Streaming") {
                Task { @MainActor in
                    await sessionVM.stopStreaming()
                }
            }
            .keyboardShortcut("d", modifiers: commandModifier)
            .disabled(!(sessionVM.activeSession?.isReplying ?? false))
            
            Section {
                Button("Regen Last Message") {
                    Task { @MainActor in
                        await sessionVM.regenLastMessage()
                    }
                }
                .keyboardShortcut("r", modifiers: commandModifier)
                
                Button("Edit Last Message") {
                    withAnimation {
                        sessionVM.editLastMessage()
                    }
                }
                .keyboardShortcut("e", modifiers: commandModifier)
                .disabled(sessionVM.activeSession?.isQuick ?? true)
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
