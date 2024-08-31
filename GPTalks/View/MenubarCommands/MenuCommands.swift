//
//  MenuCommands.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData

struct MenuCommands: Commands {
    @Environment(\.modelContext) var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(SessionVM.self) var sessionVM

    @ObservedObject var config = AppConfig.shared

    var body: some Commands {
        @Bindable var sessionVM = sessionVM
        
        SidebarCommands()
        
        CommandGroup(replacing: .newItem) {
            Button("New Session") {
                sessionVM.createNewSession(modelContext: modelContext)
            }
            .keyboardShortcut("n")
        }
        
        CommandGroup(before: .toolbar) {
            Section {
                Picker("Sidebar State", selection: $sessionVM.state) {
                    ForEach(SessionVM.ListState.allCases, id: \.self) { state in
                        Text(state.label)
                            .keyboardShortcut(state.shortcut, modifiers: [.control, .command])
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            
            Section {
                Button("Actual Size") {
                    resetFontSize()
                }
                .keyboardShortcut("o", modifiers: commandModifier)
                
                Button("Zoom In") {
                    increaseFontSize()
                }
                .keyboardShortcut("+", modifiers: commandModifier)
                
                Button("Zoom Out") {
                    decreaseFontSize()
                }
                .keyboardShortcut("-", modifiers: commandModifier)
            }
        }
        
        switch sessionVM.state {
        case .chats:
            ChatCommands()
        case .images:
            ImageCommands()
        }
        
        CommandGroup(before: .appSettings) {
            Button("Settings") {
                openWindow(id: "settings")
            }
            .keyboardShortcut(",", modifiers: .command)
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
    
    private var commandModifier: EventModifiers {
        #if targetEnvironment(macCatalyst)
        return [.command, .shift]
        #else
        return .command
        #endif
    }
}
