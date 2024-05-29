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
    #if os(macOS)
    @State var showingPanel = false
    @State private var mainWindow: NSWindow?
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(macOS) && !DEBUG
                .task {
                    KeyboardShortcuts.onKeyDown(for: .togglePanel) {
                        if !NSApp.isActive {
                            NSApp.activate(ignoringOtherApps: true)
                        }
                        showingPanel.toggle()
                    }
                }
                .background(BackgroundView(window: $mainWindow))
                .floatingPanel(isPresented: $showingPanel) {
                    PanelTextEditor {
                        showingPanel.toggle()
                        bringMainWindowToFront()
                    }
                    .environment(viewModel)
                }
#endif
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
    
#if os(macOS)
    private func bringMainWindowToFront() {
        if let window = mainWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
#endif
}

#if os(macOS)
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
#endif
