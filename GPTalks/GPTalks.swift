//
//  ChatGPTApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI
import KeyboardShortcuts

@main
struct GPTalks: App {
    @State private var viewModel = DialogueViewModel(context: PersistenceController.shared.container.viewContext)
    @State var showingPanel = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .floatingPanel(isPresented: $showingPanel, content: {
                    PanelTextEditor() {
                        showingPanel.toggle()
                    }
                    .environment(viewModel)
                })
                .task {
                    KeyboardShortcuts.onKeyDown(for: .togglePanel) {
                        showingPanel.toggle()
                    }
                }
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
