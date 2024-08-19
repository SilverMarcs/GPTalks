//
//  ConversationListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ConversationListToolbar: ToolbarContent {
    @Bindable var session: Session
    
    @State var showConfig: Bool = false
    @State var showingInspector: Bool = false
    
    @State private var currentIndex: Int = 0
    var filteredGroups: [ConversationGroup] {
        if session.searchText.count < 4 {
            return []
        }
        return session.groups.filter { group in
            group.activeConversation.content.localizedCaseInsensitiveContains(session.searchText)
        }
    }
    
    var body: some ToolbarContent {
        ToolbarItem {
            Color.clear
                .sheet(isPresented: $showingInspector) {
                    NavigationStack {
                        ChatInspector(session: session)
                        #if os(visionOS)
                            .toolbar {
                                DismissButton()
                                    .buttonStyle(.plain)
                            }
                        #endif
                    }
                }
        }
        
        #if os(macOS)
        ToolbarItem(placement: .navigation) {
            Button {
                toggleInspector()
            } label: {
                Label("Actions", systemImage: "slider.vertical.3")
            }
        }
        
        if !session.searchText.isEmpty && !filteredGroups.isEmpty {
            ToolbarItem {
                navigateButtons
            }
        }
        #else
        showInspector
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
    
    private var navigateButtons: some View {
        HStack(spacing: 2) {
            Button(action: {
                navigateToGroup(direction: .backward)
            }) {
                Image(systemName: "chevron.left")
            }
            .disabled(currentIndex == 0)
            
            Button(action: {
                navigateToGroup(direction: .forward)
            }) {
                Image(systemName: "chevron.right")
            }
            .disabled(currentIndex == filteredGroups.count - 1)
        }
    }
    
    private func navigateToGroup(direction: NavigationDirection) {
        switch direction {
        case .forward:
            if currentIndex < filteredGroups.count - 1 {
                currentIndex += 1
            }
        case .backward:
            if currentIndex > 0 {
                currentIndex -= 1
            }
        }
        
        if let group = filteredGroups[safe: currentIndex] {
            withAnimation {
                session.proxy?.scrollTo(group, anchor: .top)
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

enum NavigationDirection {
    case forward
    case backward
}

#Preview {
    @Previewable @State var showingSearchField = false
    let session = Session(config: SessionConfig())
    
    VStack {
        Text("Hello, World!")
    }
    .frame(width: 700, height: 300)
    .toolbar {
        ConversationListToolbar(session: session)
    }
}
