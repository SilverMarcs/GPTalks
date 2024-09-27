//
//  ConversationListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ConversationListToolbar: ToolbarContent {
    @Environment(ChatSessionVM.self) private var sessionVM
    @Bindable var session: ChatSession
    var providers: [Provider]
    
    @State var showingInspector: Bool = false
    @State var showingShortcuts = false

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem(placement: .navigation) {
            Button {
//                toggleInspector()
                showingShortcuts.toggle()
            } label: {
                Label("Shortcuts", systemImage: "slider.vertical.3")
            }
            .keyboardShortcut(".")
            .popover(isPresented: $showingShortcuts) {
                ConversationShortcuts()
            }
        }
        
        ToolbarItem {
            Text("Tokens: \(session.tokenCount.formatToK())")
                .foregroundStyle(.secondary)
        }
        #else
        ToolbarItem {
            Color.clear
                .sheet(isPresented: $showingInspector) {
                    ChatInspector(session: session, providers: providers, showingInspector: $showingInspector)
                }
        }
        
        ToolbarItem {
            Button {
                toggleInspector()
            } label: {
                Label("Show Inspector", systemImage: "info.circle")
            }
            .keyboardShortcut(".")
        }
        #endif
    }
    
    private var showInspector: some ToolbarContent {
        ToolbarItem {
            Button {
                toggleInspector()
            } label: {
                Label("Show Inspector", systemImage: "info.circle")
            }
            .keyboardShortcut("i", modifiers: [.command, .shift])
        }
    }
    
    private func toggleInspector() {
        #if !os(macOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
        showingInspector.toggle()
    }
}

#Preview {
    @Previewable @State var showingSearchField = false
    let session = ChatSession(config: SessionConfig())
    
    VStack {
        Text("Hello, World!")
    }
    .frame(width: 700, height: 300)
    .toolbar {
        ConversationListToolbar(session: session, providers: [])
    }
}
