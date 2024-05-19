//
//  ChatGPTApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import KeyboardShortcuts
import SwiftUI

@main
struct GPTalks: App {
    @State private var viewModel = DialogueViewModel(context: PersistenceController.shared.container.viewContext)
    @State var showingPanel = false
    @State private var mainWindow: NSWindow?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .floatingPanel(isPresented: $showingPanel, content: {
                    PanelTextEditor {
                        showingPanel.toggle()
                        bringMainWindowToFront()
                    }
                    .environment(viewModel)
                })
                .task {
                    KeyboardShortcuts.onKeyDown(for: .togglePanel) {
                        showingPanel.toggle()
                    }
                }
                .background(BackgroundView(window: $mainWindow))
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
    
    private func bringMainWindowToFront() {
        if let window = mainWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

struct BackgroundView: NSViewRepresentable {
    @Binding var window: NSWindow?
    
    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async {
            self.window = nsView.window
        }
        return nsView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
