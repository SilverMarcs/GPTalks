//
//  ChatContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

#if os(macOS)
import SwiftUI
import SwiftData

struct ChatContentView: View {
    @Environment(ChatVM.self) private var sessionVM
    @Environment(ChatVM.self) var chatVM
    
    var body: some View {
        NavigationSplitView {
            ChatList(status: chatVM.statusFilter, searchText: chatVM.searchText)
                #if os(macOS)
                .navigationSplitViewColumnWidth(min: 270, ideal: 300, max: 400)
                #endif
        } detail: {
            ChatOrSearchView()
        }
    }
}

#Preview {
    ChatContentView()
        .modelContainer(for: Chat.self, inMemory: true)
        .environment(ChatVM())
}
#endif
