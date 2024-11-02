//
//  SessionWithMatches.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/11/2024.
//

import Foundation

struct SessionWithMatches: Identifiable {
    let id: UUID
    let session: ChatSession
    var matchingConversations: [SearchedConversation]

    init(session: ChatSession, matchingConversations: [SearchedConversation]) {
        self.id = UUID()
        self.session = session
        self.matchingConversations = matchingConversations
    }
}
