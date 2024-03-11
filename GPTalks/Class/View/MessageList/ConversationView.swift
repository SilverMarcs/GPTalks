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
                if conversation.role == "user" {
                    UserMessageView(conversation: conversation, session: session)
#if !os(macOS)
                        .padding(.vertical, -20)
#endif
                }
                
                if conversation.role == "assistant" {
                    if ChatTool.allCases.map({ $0.rawValue }).contains(conversation.content) {
                        ToolCallView(conversation: conversation, session: session)
                #if !os(macOS)
                        .padding(.bottom, session.bottomPadding(for: conversation))
                #endif
                        
                    } else {
                        AssistantMessageView(conversation: conversation, session: session)
                    }
                }
            }
            #if os(macOS)
            .opacity(0.9)
            #endif

            if session.conversations.firstIndex(of: conversation) == session.resetMarker {
                ContextResetDivider(session: session)
                    .padding()
            }
        }
    }
}
