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
    
    @State var showingInspector: Bool = false
    @State var showingShortcuts = false

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem(placement: .navigation) {
            Button {
                showingShortcuts.toggle()
            } label: {
                Label("Shortcuts", systemImage: "slider.vertical.3")
            }
            .popover(isPresented: $showingShortcuts) {
                ConversationShortcuts()
            }
        }
        
        ToolbarItem {
            Text("Tokens: \(session.tokenCount.formatToK())")
                .foregroundStyle(.secondary)
        }
        #endif
        
        ToolbarItem {
            Button {
                toggleInspector()
            } label: {
                Label("Show Inspector", systemImage: "info.circle")
            }
            .keyboardShortcut(".")
            .sheet(isPresented: $showingInspector) {
                ChatInspector(session: session)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }
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
    VStack {
        Text("Hello, World!")
    }
    .frame(width: 700, height: 300)
    .toolbar {
        ConversationListToolbar(session: .mockChatSession)
    }
}
