//
//  ConversationToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct ConversationListToolbar: ToolbarContent {
    @Bindable var session: Session
    @Query var providers: [Provider]
    
    @State var isShowSysPrompt: Bool = false
    
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
            deleteLastMessage
            editLastMessage
            resetLastContext
            regenLastMessage
        }
        #endif
    }
    private var regenLastMessage: some View {
        Button("Regen Last Message") {
            print("here1")
            if session.isStreaming { return }
            print("here2")
            
            if let lastGroup = session.groups.last {
                if lastGroup.role == .user {
                    lastGroup.setupEditing()
                    Task { @MainActor in
                        await lastGroup.session?.sendInput()
                    }
                } else if lastGroup.role == .assistant {
                    print("here")
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
