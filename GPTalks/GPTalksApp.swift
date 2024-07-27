//
//  GPTalksApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData

@main
struct GPTalksApp: App {
    @Environment(\.openWindow) private var openWindow
    @State private var sessionVM = SessionVM()
    @State private var isMainWindowActive = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionVM)
            #if os(macOS)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let window = NSApplication.shared.windows.first {
                            window.identifier = NSUserInterfaceItemIdentifier("main")
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { notification in
                    if let window = notification.object as? NSWindow, window.identifier == NSUserInterfaceItemIdentifier("main") {
                        isMainWindowActive = true
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification)) { notification in
                    if let window = notification.object as? NSWindow, window.identifier == NSUserInterfaceItemIdentifier("main") {
                        isMainWindowActive = false
                    }
                }
            #endif
        }
        .modelContainer(sharedModelContainer)
        .commands {
            InspectorCommands()
            
            if isMainWindowActive {
                MenuCommands(sessionVM: sessionVM)
            }
            
            CommandGroup(after: .sidebar) {
                Button("Settings") {
                    openWindow(id: "settings")
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }

        #if os(macOS)
        Window("Settings", id: "settings") {
            SettingsView()
            
        }
//        .restorationBehavior(.disabled)
        .modelContainer(sharedModelContainer)
        #endif
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Session.self,
            Conversation.self,
            Provider.self,
            AIModel.self,
            ConversationGroup.self,
            SessionConfig.self,
            ImageSession.self,
            ImageGeneration.self,
            ImageConfig.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}


extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}

func isPadOS() -> Bool {
    #if os(macOS)
    return false
    #else
    return UIDevice.current.userInterfaceIdiom == .pad
    #endif
}
