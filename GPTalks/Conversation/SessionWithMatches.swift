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
    var matchedConversations: [MatchedConversation]

    init(session: ChatSession, matchedConversations: [MatchedConversation]) {
        self.id = UUID()
        self.session = session
        self.matchedConversations = matchedConversations
    }
}
