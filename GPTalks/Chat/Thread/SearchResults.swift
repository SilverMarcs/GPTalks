//
//  MatchedSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/11/2024.
//

import Foundation

// TODO: rename
struct MatchedSession: Identifiable {
    let id: UUID = UUID()
    let chat: Chat
    var matchedThreads: [MatchedThread]
}

struct MatchedThread: Identifiable, Hashable {
    let id: UUID = UUID()
    let thread: Thread
    let chat: Chat
}
