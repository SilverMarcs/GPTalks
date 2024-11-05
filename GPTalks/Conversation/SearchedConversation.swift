//
//  SearchedConversation.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/11/2024.
//

import Foundation
import SwiftUI

struct MatchedConversation: Identifiable, Hashable {
    let id: UUID
    let conversation: Conversation
    let session: ChatSession

    init(conversation: Conversation, session: ChatSession) {
        self.id = UUID()
        self.conversation = conversation
        self.session = session
    }
}
