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
        .padding(.horizontal, padding)
        
        SessionListCards()
            .padding(.horizontal, padding)
        #endif
        
        SessionList(searchString: sessionVM.searchText)
    }
    
    var padding: CGFloat {
        #if os(macOS)
        return 10
        #else
        return 15
        #endif
    }
}

#Preview {
    SessionListSidebar()
}
