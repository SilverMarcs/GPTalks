//
//  SessionListSidebar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI

struct SessionListSidebar: View {
    @Environment(SessionVM.self) private var sessionVM
    
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        #if os(macOS)
        SessionSearch("Search", text: $sessionVM.searchText) {
            sessionVM.searchText = ""
        }
        .padding(.horizontal, 10)
        #endif
        
        Group {
            if sessionVM.state == .chats {
                SessionList(searchString: sessionVM.searchText)
            } else {
                ImageSessionList(searchString: sessionVM.searchText)
            }
        }
        .toolbar {
            SessionListToolbar()
        }
        #if os(macOS)
        .frame(minWidth: 240)
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .padding(.top, -10)
        #else
        .navigationTitle(sessionVM.state.rawValue.capitalized)
        .listSectionSeparator(.hidden)
        .listStyle(.insetGrouped)
        .searchable(text: $sessionVM.searchText)
        #endif
    }
}

#Preview {
    SessionListSidebar()
}
