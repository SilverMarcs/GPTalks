//
//  SessionListSidebar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI

struct SessionListSidebar: View {
    @Environment(SessionVM.self) private var sessionVM
    
    @FocusState private var isSidebarFocused: Bool
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        #if os(macOS)
        CustomSearchField("Search", text: $sessionVM.searchText)
        .padding(.horizontal, 10)
        #endif
        
        Group {
            if sessionVM.state == .chats {
                SessionList()
                    .focused($isSidebarFocused)
            } else {
                ImageSessionList(searchString: sessionVM.searchText)
                    .focused($isSidebarFocused)
            }
        }
        .toolbar {
            SessionListToolbar()
            
            #if os(macOS)
            ToolbarItemGroup(placement: .keyboard) {
                Button("Focus sidebar") {
                    AppConfig.shared.sidebarFocus = true
                    isSidebarFocused = true
                }
                .keyboardShortcut(.leftArrow, modifiers: [.command, .option])
                
                Button("Focus Chat") {
                    AppConfig.shared.sidebarFocus = false
                }
                .keyboardShortcut(.rightArrow, modifiers: [.command, .option])
            }
            #endif
        }
        #if os(macOS)
        .frame(minWidth: 240)
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .padding(.top, -10)
        #else
        .navigationTitle(sessionVM.state.rawValue.capitalized)
        .listSectionSeparator(.hidden)
        .listStyle(.sidebar)
        .searchable(text: $sessionVM.searchText)
        #endif
    }
}

#Preview {
    SessionListSidebar()
}
