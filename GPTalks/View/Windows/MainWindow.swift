//
//  MainWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/08/2024.
//

import SwiftUI
import TipKit
import SwiftData

struct MainWindow: Scene {
    @Environment(\.modelContext) private var modelContext
    @FocusState var isMainWindowFocused
    @State private var isQuick = false
    
    var body: some Scene {
        #if os(macOS)
        Window("GPTalks", id: "main") {
            commonContent
//                .windowToolbarFullScreenVisibility(.onHover)
                .focusable()
                .focusEffectDisabled()
                .focused($isMainWindowFocused)
        }
        .commands {
            MenuCommands(isMainWindowFocused: _isMainWindowFocused)
        }
        #else
        WindowGroup(id: "main") {
            commonContent
        }
        #endif
    }
    
    var commonContent: some View {
        ContentView()
            .environment(\.isQuick, isQuick)
            .task {
                try? Tips.configure([.datastoreLocation(.applicationDefault)])
                initialSetup()
            }
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
}
