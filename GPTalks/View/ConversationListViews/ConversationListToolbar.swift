//
//  ConversationListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData

struct ConversationListToolbar: CustomizableToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ChatSessionVM.self) private var sessionVM
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var session: ChatSession
    
    @State var showingInspector: Bool = false
    @State var showingShortcuts = false
    
    var body: some CustomizableToolbarContent {
        ToolbarItem(id: "chat-inspector-toggle", placement: horizontalSizeClass == .compact ? .primaryAction : .navigation) {
            Button {
                toggleInspector()
            } label: {
                Label("Shortcuts", systemImage: horizontalSizeClass == .compact ? "info.circle" : "slider.vertical.3")
            }
            .keyboardShortcut(".")
            .sheet(isPresented: $showingInspector) {
                ChatInspector(session: session)
                    .presentationDetents(horizontalSizeClass == .compact ? [.medium, .large] : [.large])
                    .presentationDragIndicator(.hidden)
            }
        }
        .customizationBehavior(.disabled)
        
        #if os(macOS)
        ToolbarItem(id: "shortcuts-popover", placement: .primaryAction) {
            Button {
                showingShortcuts.toggle()
            } label: {
                Label("Show Inspector", systemImage: "info.circle")
            }
            .popover(isPresented: $showingShortcuts) {
                ConversationShortcuts()
            }
        }
        .defaultCustomization(.visible)
        
        if config.showStatusBar {
            ToolbarItem(id: "status-bar", placement: .favoritesBar) {
                ConversationStatusBar(session: session)
                    .padding(.horizontal, 5)
            }
        }
        #endif
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

#if os(macOS)
extension ToolbarItemPlacement {
    static let favoritesBar = accessoryBar(id: "conv-status-bar")
}
#endif
