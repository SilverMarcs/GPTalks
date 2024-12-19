//
//  ChatGPTApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI

@main
struct GPTalks: App {
    @State private var viewModel = DialogueViewModel(context: PersistenceController.shared.container.viewContext)
    #if os(macOS)
    @State var showingPanel = false
    @State private var mainWindow: NSWindow?
    @State var showAdditionalContent = false
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(viewModel)
        .commands {
            CommandGroup(after: .sidebar) {
                Section {
                    Button("Toggle Markdown") {
                        AppConfiguration.shared.isMarkdownEnabled.toggle()
                    }
                }
                
                Section {
                    Button(viewModel.isExpanded ? "Collapse Chat List" : "Expand Chat List") {
                        withAnimation {
                            viewModel.isExpanded.toggle()
                        }
                    }
                    
                    Button("Image Generations") {
                        viewModel.toggleImageAndChat()
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
