//
//  IOSWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 28/09/2024.
//

import SwiftUI
import SwiftData

struct IOSWindow: Scene {
    @Environment(ListStateVM.self) private var listStateVM
    @Environment(ChatSessionVM.self) private var chatVM
    @Environment(ImageSessionVM.self) private var imageVM
    
    var body: some Scene {
        WindowGroup("Chats", id: "chats") {
            NavigationSplitView {
                switch listStateVM.state {
                case .chats:
                    ChatSessionList()
                case .images:
                    ImageSessionList()
                }
            } detail: {
                switch listStateVM.state {
                case .chats:
                    if let chatSession = chatVM.activeSession {
                        ConversationList(session: chatSession)
                    } else {
                        Text("^[\(chatVM.chatSelections.count) Chat Session](inflect: true) Selected")
                    }
                case .images:
                    if let imageSession = imageVM.activeImageSession {
                        ImageGenerationList(session: imageSession)
                    } else {
                        Text("^[\(imageVM.imageSelections.count) Image Session](inflect: true) Selected")
                    }
                }
            }
        }
    }
}

@Observable class ListStateVM {
    var state: ListState = .chats
    
    enum ListState: String, CaseIterable {
        case chats
        case images
    }
}
