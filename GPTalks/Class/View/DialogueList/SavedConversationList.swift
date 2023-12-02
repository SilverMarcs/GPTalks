//
//  SavedConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/12/2023.
//

import SwiftUI

struct SavedConversationList: View {
    @Binding var dialogueSessions: [DialogueSession]
    
    var body: some View {
        let savedConversations = dialogueSessions.flatMap { dialogueSession -> [Conversation] in
            return dialogueSession.conversations.filter { $0.saved }
        }
        
        List(savedConversations, id: \.self) { conversation in
            MessageMarkdownView(text: conversation.content)
                .textSelection(.enabled)
                .bubbleStyle(isMyMessage: false)
        }
    }
}
