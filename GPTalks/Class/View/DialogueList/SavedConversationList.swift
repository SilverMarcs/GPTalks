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
        let savedConversations: [Conversation] = dialogueSessions.flatMap { dialogueSession -> [Conversation] in
            return dialogueSession.conversations.filter { $0.saved }
        }
        
        List(savedConversations, selection: $selectedConversation) { conversation in
            NavigationLink(destination: MessageView(content: conversation.content)) {
                Text(conversation.content)
                    .font(.system(size: 14))
                    .lineLimit(2)
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
