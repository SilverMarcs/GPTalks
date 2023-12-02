//
//  SavedConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/12/2023.
//

import SwiftUI

struct SavedConversationList: View {
    @Binding var dialogueSessions: [DialogueSession]
    @State var selectedConversation: Conversation?

    var body: some View {
        let savedConversations: [ConversationWithTitle] = dialogueSessions.flatMap { dialogueSession -> [ConversationWithTitle] in
            dialogueSession.conversations.filter { $0.saved }.map { ConversationWithTitle(conversation: $0, title: dialogueSession.title) }
        }

        List(savedConversations, selection: $selectedConversation) { conversationWithTitle in
            NavigationLink(destination: MessageView(conversationWithTitle: conversationWithTitle).background(.background)) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(conversationWithTitle.title)
                        .font(.body)
                        .bold()
                    Text(conversationWithTitle.conversation.content)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .font(.body)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .leading
                        )
                }
                .padding(3)
            }
            .navigationTitle("Saved Conversations")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

struct MessageView: View {
    var conversationWithTitle: ConversationWithTitle

    var body: some View {
        ScrollView {
            MessageMarkdownView(text: conversationWithTitle.conversation.content)
                .textSelection(.enabled)
                .bubbleStyle(isMyMessage: false)
                .padding()
            Spacer()
        }
        .navigationTitle(conversationWithTitle.title)
        .background(.background)
    }
}

struct ConversationWithTitle: Identifiable {
    let id = UUID()
    let conversation: Conversation
    let title: String
}
