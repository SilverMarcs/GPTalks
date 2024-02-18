//
//  ConversationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

struct ConversationView: View {
//    @Environment(DialogueViewModel.self) private var viewModel
    var session: DialogueSession
    var conversation: Conversation

    var body: some View {
        VStack(spacing: spacing) {
            Group {
                if conversation.role == "user" {
                    UserMessageView(conversation: conversation, session: session)
                        .padding(.leading, horizontalPadding)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                if conversation.role == "assistant" {
                    AssistantMessageView(conversation: conversation, session: session)
                        .padding(.trailing, horizontalPadding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            #if os(macOS)
            .opacity(0.9)
            #endif
            .transition(.opacity)

            if session.conversations.firstIndex(of: conversation) == session.resetMarker {
                ContextResetDivider(session: session)
                    .padding(.vertical)
            }

            DeleteBtn
                .opacity(0)
        }
    }

    private var DeleteBtn: some View {
        Button("hidden") {
            if let lastConversation = session.conversations.last {
                session.removeConversation(lastConversation)
            }
        }
        .keyboardShortcut(.delete, modifiers: .command)
        .frame(width: 1, height: 1)
    }

    private var spacing: CGFloat {
        #if os(macOS)
            return 8
        #else
            return 2
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
