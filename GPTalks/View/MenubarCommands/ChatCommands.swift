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
        CommandGroup(replacing: .newItem) {
            Button("New Session") {
                sessionVM.createNewSession()
            }
            .keyboardShortcut("n")
        }
        
        CommandGroup(before: .toolbar) {
            Section {
                Button("Actual Size") {
                    resetFontSize()
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Zoom In") {
                    increaseFontSize()
                }
                .keyboardShortcut("+", modifiers: .command)
                
                Button("Zoom Out") {
                    decreaseFontSize()
                }
                .keyboardShortcut("-", modifiers: .command)
            }
        }
        
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
                Button("Edit Last Message") {
                    withAnimation {
                        sessionVM.editLastMessage()
                    }
                }
                .keyboardShortcut("e", modifiers: .command)
                .disabled(sessionVM.activeSession?.isQuick ?? true)
                
                Button("Regen Last Message") {
                    Task { @MainActor in
                        await sessionVM.regenLastMessage()
                    }
                }
                .keyboardShortcut("r", modifiers: .command)
            }
            
            Section {
                Button("Reset Context") {
                    sessionVM.resetLastContext()
                }
                .keyboardShortcut("k", modifiers: .command)
                
                Button("Delete Last Message") {
                    sessionVM.deleteLastMessage()
                }
                .keyboardShortcut(.delete, modifiers: .command)
            }
        }
    }
    
    private func increaseFontSize() {
        config.fontSize = min(config.fontSize + 1, 25)
    }
    
    private func decreaseFontSize() {
        config.fontSize = max(config.fontSize - 1, 8)
    }
    
    private func resetFontSize() {
        config.fontSize = 13
    }
}
