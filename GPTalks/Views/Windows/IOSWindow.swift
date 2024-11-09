//
//  IOSWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 28/09/2024.
//

import SwiftUI
import SwiftData

#if !os(macOS)
struct IOSWindow: Scene {
    @Environment(SettingsVM.self) private var listStateVM
    @Environment(ChatVM.self) private var chatVM
    @Environment(ImageVM.self) private var imageVM
    
    @State private var showSettings = false
    
    var body: some Scene {
        WindowGroup("Chats", id: "chats") {
            NavigationSplitView {
                if !chatVM.searchResults.isEmpty {
                    ChatOrSearchView()
                } else {
                    Group {
                        switch listStateVM.listState {
                        case .chats:
                            ChatList()
                        case .images:
                            ImageList()
                        }
                    }
                    .toolbar {
                        iosToolbar
                    }
                }
            } detail: {
                switch listStateVM.listState {
                case .chats:
                    if let chat = chatVM.activeChat {
                        ChatDetail(chat: chat)
                            .id(chat.id)
                    } else {
                        Text("^[\(chatVM.chatSelections.count) Chat Session](inflect: true) Selected")
                    }
                case .images:
                    if let imageSession = imageVM.activeImageSession {
                        ImageDetail(session: imageSession)
                    } else {
                        Text("^[\(imageVM.selections.count) Image Session](inflect: true) Selected")
                    }
                }
            }
        }
    }
    
    var iosToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                Button(action: { showSettings.toggle() }) {
                    Label("Settings", systemImage: "gear")
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
                    .labelStyle(.titleOnly)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}
#endif
