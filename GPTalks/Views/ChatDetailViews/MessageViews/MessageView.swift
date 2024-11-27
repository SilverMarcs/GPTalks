//
//  MessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct MessageView: View {
    var message: MessageGroup
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            switch message.role {
            case .user:
                UserMessage(message: message)
            case .assistant:
                if message.toolCalls.isEmpty {
                    AssistantMessage(message: message)
                } else {
                    ToolCallView(message: message)
                }
            case .tool:
                ToolResponseMessage(message: message)
            default:
                Text("Unknown role")
            }
            
            if message.chat?.contextResetPoint == message {
                ContextResetDivider() { message.chat?.resetContext(at: message)}
                    .padding(.vertical)
            }
        }
        #if os(iOS)
        .opacity(0.9)
        #endif
    }
}


#Preview {
    VStack {
        MessageView(message: .mockUserGroup)
        MessageView(message: .mockAssistantGroup)
    }
    .frame(width: 400)
    .padding()
}
