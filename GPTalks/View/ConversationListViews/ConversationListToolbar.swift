//
//  ConversationToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct ConversationListToolbar: ToolbarContent {
    @Bindable var session: Session
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Menu {

            } label: {
                Image(systemName: "slider.vertical.3")
            }
            .menuIndicator(.hidden)
        }
        
        #if os(macOS)
        ToolbarItemGroup(placement: .keyboard) {
            sendMessage
            deleteLastMessage
            editLastMessage
            resetLastContext
            regenLastMessage
        }
        #endif
    }
    
    private var sendMessage: some View {
        Button("Send") {
            Task {
                await session.sendInput()
            }
        }
        .keyboardShortcut(.return, modifiers: .command)
    }
    
    private var regenLastMessage: some View {
        Button("Regen Last Message") {
            if session.isStreaming { return }
            
            if let lastGroup = session.groups.last {
                if lastGroup.role == .user {
                    lastGroup.setupEditing()
                    Task { @MainActor in
                        await lastGroup.session?.sendInput()
                    }
                } else if lastGroup.role == .assistant {
                    session.regenerate(group: lastGroup)
                }
            }
        }
        .keyboardShortcut("r", modifiers: .command)
    }
    
    private var deleteLastMessage: some View {
        Button("Delete Last Message") {
            if session.isStreaming { return }
            
            if let lastGroup = session.groups.last {
                session.deleteConversationGroup(lastGroup)
            }
        }
        .keyboardShortcut(.delete, modifiers: .command)
    }
    
    private var resetLastContext: some View {
        Button("Reset Context at Last Message") {
            if let lastGroup = session.groups.last {
                session.resetContext(at: lastGroup)
            }
        }
        .keyboardShortcut("k", modifiers: .command)
    }
    
    private var editLastMessage: some View {
        Button("Edit Last Message") {
            guard let lastUserGroup = session.groups.last(where: { $0.role == .user }) else {
                return
            }
            lastUserGroup.setupEditing()
        }
        .keyboardShortcut("e", modifiers: .command)
    }
}
