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
    @Environment(ChatVM.self) var chatVM
    
    var body: some View {
        NavigationSplitView {
            ChatList(status: chatVM.statusFilter)
                #if os(macOS)
                .navigationSplitViewColumnWidth(min: 270, ideal: 300, max: 400)
                #endif
        } detail: {
            if let chat = chatVM.activeChat, chat.status != .quick {
                ChatDetail(chat: chat)
                    #if !os(macOS)
                    .id(chat.id)
                    #endif
            } else {
                Text("^[\(chatVM.selections.count) Chat Session](inflect: true) Selected")
                    .font(.title)
                    .fullScreenBackground()
            }
        }
    }
}

#Preview {
    ChatContentView()
        .modelContainer(for: Chat.self, inMemory: true)
        .environment(ChatVM())
}
#endif
