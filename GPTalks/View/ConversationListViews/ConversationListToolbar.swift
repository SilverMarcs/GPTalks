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
        
        ToolbarItemGroup(placement: .keyboard) {
            deleteLastMessage
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
            .frame(maxWidth: 150)
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
    }
    
    private var deleteLastMessage: some View {
        Button("Delete Last Message") {
            if let lastConversation = session.groups.last {
                withAnimation {
                    session.deleteConversationGroup(lastConversation)
                }
            }
        }
        .keyboardShortcut(.delete, modifiers: .command)
    }
}
