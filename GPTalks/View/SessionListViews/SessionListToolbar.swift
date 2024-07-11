//
//  SessionListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI
import SwiftData

struct SessionListToolbar: ToolbarContent {
    @Environment(SessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    @ObservedObject var providerManager = ProviderManager.shared
    
    @Query(sort: \Provider.date, order: .reverse) var providers: [Provider]
    
    var body: some ToolbarContent {
#if os(iOS)
        ToolbarItem(placement: .leading) {
            Button(action: { showSettings.toggle() }) {
                Label("Settings", systemImage: "gear")
            }
        }
#endif
        ToolbarItem {
            Spacer()
        }
        
        ToolbarItem {
            Button(action: addItem) {
                Label("Add Item", systemImage: "square.and.pencil")
            }
            .keyboardShortcut("n", modifiers: .command)
        }
    }
    
    private func addItem() {
        sessionVM.addItem(providerManager: providerManager, providers: providers, modelContext: modelContext)
    }
}

#Preview {
    VStack {
        Text("Hi")
    }.toolbar  {
        SessionListToolbar()
    }
}
