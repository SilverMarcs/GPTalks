//
//  MainWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/08/2024.
//

import SwiftUI
import SwiftData

struct ChatWindow: Scene {
    var body: some Scene {
        Window("Chats", id: WindowID.chats) {
            ChatContentView()
        }
        .commands {
            ChatCommands()
        }

        WindowGroup(for: Chat.ID.self) { $id in
            if let id = id {
                ChatDetailWrapper(id: id)
                    .environment(ChatVM())
                    .modelContainer(DatabaseService.shared.container)
            } else {
                Text("No ID")
            }
        }
        .defaultSize(.init(width: 1000, height: 800))
        .restorationBehavior(.disabled)
    }
}

struct ChatDetailWrapper: View {
    @Environment(ChatVM.self) private var chatVM
    @Query private var chats: [Chat]
    let id: Chat.ID

    init(id: Chat.ID) {
        self.id = id
        self._chats = Query(filter: #Predicate<Chat> { chat in
            chat.id == id
        })
    }

    var body: some View {
        @Bindable var chatVM = chatVM
        
        if let chat = chats.first {
            ChatDetail(chat: chat)
                .searchable(text: $chatVM.searchText)
        } else {
            Text("Chat not found")
        }
    }
}
