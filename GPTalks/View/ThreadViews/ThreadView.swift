//
//  ThreadView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct ThreadView: View {
    var thread: Thread
    
    var body: some View {
        switch thread.role {
        case .user:
            UserMessage(thread: thread)
        case .assistant:
            if thread.toolCalls.isEmpty {
                AssistantMessage(thread: thread)
            } else {
                ToolCallView(thread: thread)
            }
        case .tool:
            ToolResponseView(thread: thread)
        default:
            Text("Unknown role")
        }
    }
}


#Preview {
    VStack {
        ThreadView(thread: .mockUserThread)
        ThreadView(thread: .mockAssistantThread)
    }
    .frame(width: 400)
    .padding()
}
