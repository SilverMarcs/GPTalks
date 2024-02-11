//
//  ChatGPTApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI
import HotKey

@main
struct GPTalks: App {
    @State private var viewModel = DialogueViewModel(context: PersistenceController.shared.container.viewContext)
    
    let hotKey = HotKey(key: .space, modifiers: [.option], keyDownHandler: {NSApp.activate(ignoringOtherApps: true)})
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(viewModel)
        .commands {
            CommandMenu("Session") {
                Section {
                    Button("Regenerate") {
                        Task { @MainActor in
                            await viewModel.selectedDialogue?.regenerateLastMessage()
                        }
                    }
                    .keyboardShortcut("r", modifiers: .command)
                    
                    Button("Deselect Session") {
                        viewModel.selectedDialogue = nil
                    }
                    .keyboardShortcut(.escape, modifiers: .command)
                    
                }
                
                Section {
                    Button("Reset Context") {
                        viewModel.selectedDialogue?.resetContext()
                    }
                    .keyboardShortcut("k", modifiers: .command)
                    
                    Button("Delete all messages") {
                        viewModel.selectedDialogue?.removeAllConversations()
                    }
                    .keyboardShortcut(.delete, modifiers: [.command, .shift])
                }
            }
            
            CommandGroup(after: .sidebar) {
                Button(viewModel.isArchivedSelected ? "Active Chats" : "Archived Chats") {
                    viewModel.toggleArchivedStatus()
                }
                .keyboardShortcut("a", modifiers: [.command, .shift])
            }
        }
#if os(macOS)
        Settings {
            MacOSSettingsView()
        }
#endif
    }
}
