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
    @Environment(SettingsVM.self) var settingsVM
    
    var body: some Commands {
        @Bindable var chatVM = chatVM
        
        CommandGroup(replacing: .newItem) {
            Button("New Session") {
                chatVM.createNewSession()
            }
            .keyboardShortcut("n")
        }
        
        CommandGroup(before: .toolbar) {
            Section {
                Picker("Chat Status", selection: $chatVM.statusFilter) {
                    ForEach([ChatStatus.normal, .starred, .archived]) { status in
                        Text(status.name)
                            .tag(status)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
            
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
                .disabled(!(chatVM.activeChat?.isReplying ?? false) || chatVM.activeChat?.status == .quick)
                
                Button("Stop Streaming") {
                    chatVM.stopStreaming()
                }
                .keyboardShortcut("d")
                .disabled(!(chatVM.activeChat?.isReplying ?? false))
            }
            
            Section {
                Button("Edit Last Message") {
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
