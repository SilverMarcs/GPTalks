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
//            .id(String.topID)
            .padding(.horizontal, 10)
        #endif
        
        ChatSessionList(providers: providers)
    }
}

#Preview {
    SessionListSidebar(providers: [])
}
