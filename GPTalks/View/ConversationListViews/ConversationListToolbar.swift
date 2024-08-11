//
//  ConversationListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ConversationListToolbar: ToolbarContent {
    @Bindable var session: Session
    
    @State private var isExportingJSON = false
    @State private var isExportingMarkdown = false
    
    @State private var currentIndex: Int = 0
    var filteredGroups: [ConversationGroup] {
        if session.searchText.count < 4 {
            return []
        }
        return session.groups.filter { group in
            group.role == .user &&
            group.activeConversation.content.localizedCaseInsensitiveContains(session.searchText)
        }
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Menu {
                Button {
                    isExportingJSON = true
                } label: {
                    Label("Export JSON", systemImage: "ellipsis.curlybraces")
                }
                
                Button {
                    isExportingMarkdown = true
                } label: {
                    Label("Export Markdown", systemImage: "richtext.page")
                }
            } label: {
                Label("Actions", systemImage: "slider.vertical.3")
            }
            .menuIndicator(.hidden)
        }
        
        ToolbarItem {
            Color.clear
            .sessionExporter(isExporting: $isExportingJSON, sessions: [session])
        }
        
        ToolbarItem {
            Color.clear
            .markdownSessionExporter(isExporting: $isExportingMarkdown, session: session)
        }
        
        if !session.searchText.isEmpty && !filteredGroups.isEmpty {
            ToolbarItem {
                navigateButtons
            }
        }
        
        #if os(macOS)
        ToolbarItem {
            CustomSearchField("Search", text: $session.searchText, height: 28, showFocusRing: true)
            .frame(width: 220)
        }
        #endif
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
