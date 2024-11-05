//
//  ThreadGroupView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct ThreadGroupView: View {
    @Environment(ChatVM.self) var sessionVM
    var group: ThreadGroup

    var body: some View {
        ThreadView(conversation: group.activeThread)
            #if os(iOS)
            .opacity(0.9)
            #endif
    }
}

struct ThreadView: View {
    var conversation: Thread
    
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
        ThreadGroupView(group: .mockUserThreadGroup)
        ThreadGroupView(group: .mockAssistantThreadGroup)
    }
    .frame(width: 400)
    .padding()
}
