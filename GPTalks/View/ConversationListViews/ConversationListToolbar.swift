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
                Section {
                    generateTitle
                }
                
                Section {
                    deleteAllMessages
                }
            } label: {
                Image(systemName: "slider.vertical.3")
            }
            .menuIndicator(.hidden)
        }
        
        ToolbarItemGroup {
            Picker("Provider", selection: $session.config.provider) {
                ForEach(providers.sorted(by: { $0.date < $1.date }), id: \.self) { provider in
                    Text(provider.name).tag(provider.id)
                }
            }
            
            Slider(value: $session.config.temperature, in: 0 ... 2, step: 0.2) {} minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("2")
            }
            .frame(width: 130)
            
            Picker("Model", selection: $session.config.model) {
                ForEach(session.config.provider.models.sorted(by: { $0.name < $1.name }), id: \.self) { model in
                    Text(model.name)
                }
            }
            .onChange(of: session.config.provider) {
                session.config.model = session.config.provider.chatModel
            }
            .frame(width: 110)
        }
        
        ToolbarItem(placement: .automatic) {
            Button {
                isShowSysPrompt.toggle()
            } label: {
                Image(systemName: "info.circle")
            }
            .popover(isPresented: $isShowSysPrompt) {
                ConversationTrailingPopup(session: session)
            }
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
    
    private var generateTitle: some View {
        Button("Generate Title") {
            if session.isStreaming { return }
            
            Task {
                await session.generateTitle(forced: true)
            }
        }
    }
    
    private var deleteAllMessages: some View {
        Button("Delete All Messages") {
            if session.isStreaming { return }
            
            session.deleteAllConversations()
        }
    }
    
    private var regenLastMessage: some View {
        Button("Regen Last Message") {
            if session.isStreaming { return }
            
            if let lastGroup = session.groups.last {
                session.regenerate(group: lastGroup)
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
            withAnimation {
                lastUserGroup.setupEditing()
            }
        }
        .keyboardShortcut("e", modifiers: .command)
    }
}
