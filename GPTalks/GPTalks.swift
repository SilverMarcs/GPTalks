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
    
    #if os(macOS)
    let hotKey = HotKey(key: .space, modifiers: [.option], keyDownHandler: {NSApp.activate(ignoringOtherApps: true)})
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(viewModel)
        .commands {
//            CommandMenu("Session") { }
            
            CommandGroup(after: .sidebar) {
                Section {
                    Button("Toggle Markdown") {
                        AppConfiguration.shared.isMarkdownEnabled.toggle()
                    }
                }
                
                Section {
                    Button("Image Generations") {
                        viewModel.tggleImageAndChat()
                    }
                    .keyboardShortcut("i", modifiers: [.command, .shift])
                }
            }
        }
#if os(macOS)
        Settings {
            MacOSSettingsView()
        }
#endif
    }
}
