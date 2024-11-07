//
//  ChatListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/13/24.
//

import SwiftUI

struct ChatListToolbar: ToolbarContent {
    @Environment(ChatVM.self) private var chatVM
    @Environment(\.providers) private var providers
    
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
                    Menu {
                        ForEach(provider.chatModels) { model in
                            Button(model.name) {
                                chatVM.createNewSession(provider: provider, model: model)
                            }
                        }
                    } label: {
                        Label(provider.name, systemImage: "cpu")
                    }
                }
            } label: {
                Label("Add Item", systemImage: "square.and.pencil")
            } primaryAction: {
                chatVM.createNewSession()
            }
            .menuIndicator(.hidden)
            .popoverTip(NewSessionTip())
        }
    }
}

#Preview {
    VStack {
        Text("Hi")
    }.toolbar  {
        ChatListToolbar()
    }
}
