//
//  ChatCommands.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ChatCommands: Commands {
    @ObservedObject var config = AppConfig.shared
    @Environment(ChatVM.self) var sessionVM
    
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
                    await sessionVM.sendPrompt()
                }
            }
            .keyboardShortcut(.return)
            .disabled(!(sessionVM.activeChat?.isReplying ?? false) && sessionVM.activeChat?.isQuick ?? false)
            
            Button("Stop Streaming") {
                sessionVM.stopStreaming()
            }
            .keyboardShortcut("d")
            .disabled(!(sessionVM.activeChat?.isReplying ?? false))
            
            Section {
                Button("Edit Last Message") {
                    withAnimation {
                        sessionVM.editLastMessage()
                    }
                }
                .keyboardShortcut("e")
                .disabled(sessionVM.activeChat?.isQuick ?? true)
                
                Button("Regen Last Message") {
                    Task { @MainActor in
                        await sessionVM.regenLastMessage()
                    }
                }
                .keyboardShortcut("r")
            }
            
            Section {
                Button("Delete Last Message", role: .destructive) {
                    sessionVM.deleteLastMessage()
                }
                .keyboardShortcut(.delete)
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
