//
//  ContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts

struct ContentView: View {
    @Environment(SessionVM.self) private var sessionVM
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    @ObservedObject var providerManager = ProviderManager.shared
    
    @State var showingInspector: Bool = true
    
    var body: some View {
        NavigationSplitView {
            SessionListSidebar()
                .navigationSplitViewColumnWidth(min: 240, ideal: 250, max: 300)
        } detail: {
            ConversationListDetail()
        }
        .task {
            setupShortcut()
            initialSetup()
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif
    }
    
    private func initialSetup() {
        var fetchProviders = FetchDescriptor<Provider>()
        fetchProviders.fetchLimit = 1
        
        guard try! modelContext.fetch(fetchProviders).count == 0 else { return }
        
        let openAI = Provider.factory(type: .openai)
        openAI.order = 0
        let anthropic = Provider.factory(type: .anthropic)
        anthropic.order = 1
        let google = Provider.factory(type: .google)
        google.order = 2
        
        modelContext.insert(openAI)
        modelContext.insert(anthropic)
        modelContext.insert(google)
        
        let config = SessionConfig(provider: openAI, purpose: .quick)
        let session = Session(config: config)
        config.session = session
        session.isQuick = true

        modelContext.insert(session)
        
        ProviderManager.shared.defaultProvider = openAI.id.uuidString
        ProviderManager.shared.quickProvider = openAI.id.uuidString
    }
    
    private func setupShortcut() {
        #if os(macOS)
        KeyboardShortcuts.onKeyDown(for: .togglePanel) {
            if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "quick" }) {
                if window.isVisible {
                    dismissWindow(id: "quick")
                } else {
                    openWindow(id: "quick")
                    window.makeKeyAndOrderFront(nil)
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
            } else {
                openWindow(id: "quick")
                if let newWindow = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "quick" }) {
                    newWindow.makeKeyAndOrderFront(nil)
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
            }
        }

        #endif
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Session.self, inMemory: true)
        .environment(SessionVM())
}
