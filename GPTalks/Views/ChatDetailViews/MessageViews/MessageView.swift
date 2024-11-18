//
//  MessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct MessageView: View {
    var message: Message
    
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
            
            if message.chat?.messages.firstIndex(where: { $0 == message }) == message.chat?.resetMarker {
                ContextResetDivider() { message.chat?.resetMarker = nil }
                    .padding(.vertical)
            }
        }
    }
}


#Preview {
    VStack {
        MessageView(message: .mockUserMessage)
        MessageView(message: .mockAssistantMessage)
    }
    .frame(width: 400)
    .padding()
}
