//
//  ChatCommands.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ChatCommands: Commands {
    @ObservedObject var config = AppConfig.shared
    @Environment(ChatSessionVM.self) var sessionVM
    
    var body: some Commands {
        CommandMenu("Chat") {
            Button("Send Prompt") {
                Task { @MainActor in
                    await sessionVM.sendMessage()
                }
            }
            .keyboardShortcut(.return, modifiers: .command)
            
            Button("Paste Files") {
                sessionVM.handlePaste()
            }
            .keyboardShortcut("b")
            
            Button("Stop Streaming") {
                Task { @MainActor in
                    await sessionVM.stopStreaming()
                }
            }
            .keyboardShortcut("d", modifiers: .command)
            .disabled(!(sessionVM.activeSession?.isReplying ?? false))
            
            Section {
                Button("Regen Last Message") {
                    Task { @MainActor in
                        await sessionVM.regenLastMessage()
                    }
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Button("Edit Last Message") {
                    withAnimation {
                        sessionVM.editLastMessage()
                    }
                }
                .keyboardShortcut("e", modifiers: .command)
                .disabled(sessionVM.activeSession?.isQuick ?? true)
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
