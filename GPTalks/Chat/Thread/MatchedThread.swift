//
//  MatchedThread.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/11/2024.
//

import Foundation

struct MatchedThread: Identifiable, Hashable {
    let id: UUID
    let conversation: Thread
    let session: Chat

    init(conversation: Thread, session: Chat) {
        self.id = UUID()
        self.conversation = conversation
        self.session = session
    }
}
