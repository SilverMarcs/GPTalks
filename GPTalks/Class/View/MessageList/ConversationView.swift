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
                    if conversation.content == "urlScrape" || conversation.content == "transcribe" || conversation.content == "imageGenerate" {
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

    @ViewBuilder
    private var DeleteBtn: some View {
        if let lastConversation = session.conversations.last, lastConversation == conversation {
            Button("hidden") {
//                if let lastConversation = session.conversations.last {
                    session.removeConversation(lastConversation)
//                }
            }
            .keyboardShortcut(.delete, modifiers: .command)
            .frame(width: 1, height: 1)
        }
    }

    private var spacing: CGFloat {
        #if os(macOS)
        if AppConfiguration.shared.alternateChatUi {
            return -8
        } else {
            return 8
        }
        #else
        if AppConfiguration.shared.alternateChatUi {
            return -8
        } else {
            return 2
        }
        #endif
    }

    private var horizontalPadding: CGFloat {
        #if os(iOS)
            50
        #else
            65
        #endif
    }
}
