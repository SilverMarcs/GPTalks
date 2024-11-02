//
//  ConversationGroupView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct ConversationGroupView: View {
    @Environment(ChatSessionVM.self) var sessionVM
    var group: ConversationGroup

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ConversationView(conversation: group.activeConversation)
                .padding(.top, 5)
                .environment(\.isSearch, false)
                #if os(iOS)
                .opacity(0.9)
                #endif
            
            if group.session?.groups.firstIndex(where: { $0 == group }) == group.session?.resetMarker {
                ContextResetDivider() {
                    group.session?.resetMarker = nil
                }
                .padding(.vertical)
            }
        }
    }
}

struct ConversationView: View {
    var conversation: Conversation
    
    var body: some View {
        switch conversation.role {
        case .user:
            UserMessage(conversation: conversation)
        case .assistant:
            if conversation.toolCalls.isEmpty {
                AssistantMessage(conversation: conversation)
            } else {
                ToolCallView(conversation: conversation)
            }
        case .tool:
            ToolMessage(conversation: conversation)
        default:
            Text("Unknown role")
        }
    }
}


#Preview {
    VStack {
        ConversationGroupView(group: .mockUserConversationGroup)
        ConversationGroupView(group: .mockAssistantConversationGroup)
    }
    .frame(width: 400)
    .padding()
}
