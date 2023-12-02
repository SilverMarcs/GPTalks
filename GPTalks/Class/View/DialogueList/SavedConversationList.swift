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
          return dialogueSession.conversations.filter { $0.saved }.map { ConversationWithTitle(conversation: $0, title: dialogueSession.title) }
      }

      List(savedConversations, selection: $selectedConversation) { conversationWithTitle in
          NavigationLink(destination: MessageView(content: conversationWithTitle.conversation.content).background(.background)) {
              VStack(alignment: .leading) {
                  Text(conversationWithTitle.title)
                    .font(.headline)
                  Text(conversationWithTitle.conversation.content)
                    .font(.system(size: 14))
                    .lineLimit(2)
                }
            }
        }
    }
}

struct MessageView: View {
    var content: String
    
    var body: some View {
        ScrollView {
            MessageMarkdownView(text: content)
                .textSelection(.enabled)
                .bubbleStyle(isMyMessage: false)
                .padding()
            Spacer()
        }
        .background(.background)
    }
}

struct ConversationWithTitle: Identifiable {
   let id = UUID()
   let conversation: Conversation
   let title: String
}
