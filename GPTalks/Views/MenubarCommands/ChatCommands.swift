//
//  ChatCommands.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ChatCommands: Commands {
    @ObservedObject var config = AppConfig.shared
    @Environment(ChatVM.self) var chatVM
    @FocusState var isFocused: FocusedField?
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Session") {
                Task {
                    await chatVM.createNewSession()
                }
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
            Section {
                Button("Send Prompt") {
                    Task { @MainActor in
                        await chatVM.sendPrompt()
                    }
                }
                .keyboardShortcut(.return)
                          
                Button("Stop Streaming") {
                    chatVM.stopStreaming()
                }
                .keyboardShortcut("d")
                .disabled(!(chatVM.activeChat?.isReplying ?? false))
            }
            
            Section {
                Button("Edit Last Message") {
                    isFocused = .textEditor // this isnt doing anything (on macos at least)
                    withAnimation {
                        chatVM.editLastMessage()
                    }
                }
                .keyboardShortcut("e")
                .disabled(chatVM.activeChat?.status == .quick)
                
                Button("Regen Last Message") {
                    Task { @MainActor in
                        await chatVM.regenLastMessage()
                    }
                }
                .keyboardShortcut("r")
            }
            
            Section {
                Button("Reset Context") {
                    chatVM.resetContext()
                }
                .keyboardShortcut("k")
                
                Button("Delete Last Message", role: .destructive) {
                    chatVM.deleteLastMessage()
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
