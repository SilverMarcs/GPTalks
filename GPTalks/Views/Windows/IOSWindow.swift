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
    @Environment(ListStateVM.self) private var listStateVM
    @Environment(ChatVM.self) private var chatVM
    @Environment(ImageSessionVM.self) private var imageVM
    
    var body: some Scene {
        WindowGroup("Chats", id: "chats") {
            NavigationSplitView {
                if !chatVM.searchResults.isEmpty {
                    ChatOrSearchView()
                } else {
                    switch listStateVM.state {
                    case .chats:
                        ChatList()
                    case .images:
                        ImageSessionList()
                    }
                }
            } detail: {
                switch listStateVM.state {
                case .chats:
                    if let chat = chatVM.activeChat {
                        ChatDetail(chat: chat)
                    } else {
                        Text("^[\(chatVM.chatSelections.count) Chat Session](inflect: true) Selected")
                    }
                case .images:
                    if let imageSession = imageVM.activeImageSession {
                        ImageGenerationList(session: imageSession)
                    } else {
                        Text("^[\(imageVM.selections.count) Image Session](inflect: true) Selected")
                    }
                }
            }
        }
    }
}
#endif


// TODO: this can just be env var instead of class
@Observable class ListStateVM {
    var state: ListState = .chats
    
    enum ListState: String, CaseIterable {
        case chats
        case images
    }
}
