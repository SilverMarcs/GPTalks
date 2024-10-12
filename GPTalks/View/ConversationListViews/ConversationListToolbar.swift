//
//  ConversationListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData

struct ConversationListToolbar: ToolbarContent {
    @Environment(ChatSessionVM.self) private var sessionVM
    @Bindable var session: ChatSession
    
    @State var showingInspector: Bool = false
    @State var showingShortcuts = false

    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
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
            ProviderPicker(provider: $session.config.provider, providers: providers) { provider in
                session.config.model = provider.chatModel
            }
        }
        
        ToolbarItem {
            ModelPicker(model: $session.config.model, models: session.config.provider.chatModels, label: "Model")
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
