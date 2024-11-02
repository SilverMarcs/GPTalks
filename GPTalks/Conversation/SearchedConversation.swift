//
//  SearchedConversation.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/11/2024.
//

import Foundation
import SwiftUI

struct SearchedConversation: Identifiable, Hashable {
    let id: UUID
    let conversation: Conversation
    let session: ChatSession

    init(conversation: Conversation, session: ChatSession) {
        self.id = UUID()
        self.conversation = conversation
        self.session = session
    }
}

private struct IsSearchKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isSearch: Bool {
        get { self[IsSearchKey.self] }
        set { self[IsSearchKey.self] = newValue }
    }
}

