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

    var body: some Commands {
        SidebarCommands()
        
//        InspectorCommands()
        
        if isMainWindowFocused {
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
        
//        CommandGroup(replacing: .newItem) {
//            Button("New Session") {
//                let fetchProviders = FetchDescriptor<Provider>()
//                let fetchedProviders = try! modelContext.fetch(fetchProviders)
//                
//                if let provider = ProviderManager.shared.getDefault(providers: fetchedProviders) {
//                    let config = SessionConfig(provider: provider, purpose: .chat)
//                    let newItem = Session(config: config)
//                    config.session = newItem
//                    
//                    var fetchSessions = FetchDescriptor<Session>()
//                    fetchSessions.sortBy = [SortDescriptor(\.order)]
//                    let fetchedSessions = try! modelContext.fetch(fetchSessions)
//                    
//                    withAnimation {
//                        for session in fetchedSessions {
//                            session.order += 1
//                        }
//                        
//                        newItem.order = 0
//                        modelContext.insert(newItem)
//                        sessionVM.selections = [newItem]
//                    }
//                } else {
//                    return
//                }
//            }
//        }
        
        CommandGroup(replacing: .newItem) { }
    }
}
