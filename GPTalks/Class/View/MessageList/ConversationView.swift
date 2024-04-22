//
//  ConversationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

struct ConversationView: View {
    var session: DialogueSession
    var conversation: Conversation

    var body: some View {
        VStack { // TODO dont use vstack
            Group {
                switch conversation.role {
                case .user:
                    UserMessageView(conversation: conversation, session: session)
                case .assistant:
                    AssistantMessageView(conversation: conversation, session: session)
                case .tool:
                    ToolCallView(conversation: conversation, session: session)
                case .system:
                    // never coming here
                    Text(conversation.content)
                }
            }
            .opacity(0.9)

            if session.conversations.firstIndex(of: conversation) == session.resetMarker {
                ContextResetDivider(session: session)
                    .padding()
            }
        }
    }
}
