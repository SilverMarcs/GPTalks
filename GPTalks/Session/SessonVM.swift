//
//  SessonVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

enum ListState: String {
    case chats
    case images
}

@Observable class SessionVM {
    var selections: Set<Session> = []
    var imageSelections: Set<ImageSession> = []
    
    var searchText: String = ""
    
    var state: ListState = .chats
    
    #if os(macOS)
    var chatCount: Int = 12
    #else
    var chatCount: Int = .max
    #endif
    
    func addItem(provider: Provider, sessions: [Session]?, imageSessions: [ImageSession]?, modelContext: ModelContext) {
        if state == .chats {
            addChatSession(provider: provider, sessions: sessions ?? [], modelContext: modelContext)
        } else {
            addImageSession(provider: provider, imageSessions: imageSessions ?? [], modelContext: modelContext)
        }
    }
}

func getDefaultProvider(providers: [Provider]) -> Provider? {
    if let defaultProvider = ProviderManager.shared.getDefault(providers: providers) {
        return defaultProvider
    } else if let firstProvider = providers.first {
        return firstProvider
    }
    return nil
}
