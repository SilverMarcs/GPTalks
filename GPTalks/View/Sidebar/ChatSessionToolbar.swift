//
//  ChatSessionToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/13/24.
//

import SwiftUI
import SwiftData

struct ChatSessionToolbar: ToolbarContent {
    @Environment(ChatSessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    
    @Query(filter: #Predicate<Provider> { $0.isEnabled })
    var providers: [Provider]
    
    @State private var showSettings = false
    
    var body: some ToolbarContent {
        #if !os(macOS)
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button(action: { showSettings.toggle() }) {
                    Label("Settings", systemImage: "gear")
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
                    .labelStyle(.titleOnly)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        #endif
        
        ToolbarItem { Spacer() }
        
        ToolbarItem {
            Menu {
                ForEach(providers) { provider in
                    Button(provider.name) {
                        sessionVM.createNewSession(provider: provider)
                    }
                    .keyboardShortcut(.none)
                }
            } label: {
                Label("Add Item", systemImage: "square.and.pencil")
            } primaryAction: {
                sessionVM.createNewSession()
            }
            .menuIndicator(.hidden)
            .popoverTip(NewSessionTip())
        }
//        .customizationBehavior(.disabled)
    }
}

#Preview {
    VStack {
        Text("Hi")
    }.toolbar  {
        ChatSessionToolbar()
    }
}
