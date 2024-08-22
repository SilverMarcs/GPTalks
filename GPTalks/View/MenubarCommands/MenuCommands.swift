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
    @FocusState var isMainWindowFocused: Bool
    @ObservedObject var config = AppConfig.shared

    var body: some Commands {
        @Bindable var sessionVM = sessionVM
        
        SidebarCommands()
        
//        InspectorCommands()
        
        if isMainWindowFocused {
            CommandGroup(before: .toolbar) {
                Section {
                    Picker("Sidebar State", selection: $sessionVM.state) {
                        ForEach(SessionVM.ListState.allCases, id: \.self) { state in
                            Text(state.rawValue.capitalized)
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
            
            
            
            switch sessionVM.state {
            case .chats:
                ChatCommands(sessionVM: sessionVM)
            case .images:
                ImageCommands(sessionVM: sessionVM)
            }
        }
        
        CommandGroup(before: .appSettings) {
            Button("Settings") {
                openWindow(id: "settings")
            }
            .keyboardShortcut(",", modifiers: .command)
        }
        
        CommandGroup(replacing: .newItem) {
            Button("New Session") {
                sessionVM.createNewSession(modelContext: modelContext)
            }
            .keyboardShortcut("n")
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
