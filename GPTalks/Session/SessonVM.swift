//
//  SessonVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData
import SwiftUI
import Observation

enum ListState: String {
    case chats
    case images
}

@Observable class SessionVM {
    var selections: Set<Session> = []
//    var selections: Set<AnyTreeItem> = []
    var imageSelections: Set<ImageSession> = []
    
    var searchText: String = ""
    
    var state: ListState = .chats
    
    func addItem(provider: Provider, sessions: [Session]?, imageSessions: [ImageSession]?, modelContext: ModelContext) {
        if state == .chats {
            addChatSession(provider: provider, sessions: sessions ?? [], modelContext: modelContext)
        } else {
            addImageSession(provider: provider, imageSessions: imageSessions ?? [], modelContext: modelContext)
        }
    }
}
