//
//  ConversationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

struct ConversationView: View {
    @ObservedObject var session: DialogueSession
    var conversation: Conversation
    
    var body : some View {
        if conversation.role == "user" {
            UserMessageView(conversation: conversation, session: session)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        
        if conversation.role == "assistant" {
            AssistantMessageView(conversation: conversation, session: session)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        if session.conversations.firstIndex(of: conversation) == session.resetMarker {
            ContextResetDivider(session: session)
                .padding(.vertical)
        }
    }
}
