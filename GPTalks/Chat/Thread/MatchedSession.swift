//
//  MatchedSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/11/2024.
//

import Foundation

struct MatchedSession: Identifiable {
    let id: UUID
    let session: Chat
    var matchedThreads: [MatchedThread]

    init(session: Chat, matchedThreads: [MatchedThread]) {
        self.id = UUID()
        self.session = session
        self.matchedThreads = matchedThreads
    }
}
