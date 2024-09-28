//
//  SessionListSidebar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI

struct SessionListSidebar: View {
    @Environment(ChatSessionVM.self) private var sessionVM
    @ObservedObject var config = AppConfig.shared
    var providers: [Provider]
    
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        #if os(macOS)
        CustomSearchField("Search", text: $sessionVM.searchText)
            .padding(.horizontal, 10)
        #endif
        
        ChatSessionList()
    }
}

#Preview {
    SessionListSidebar(providers: [])
}
