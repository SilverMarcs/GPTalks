//
//  ToolCallView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI

struct ToolCallView: View {
    var conversation: Conversation
    @State private var showArguments = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "hammer")
                .resizable()
                .fontWeight(.semibold)
                .frame(width: 18, height: 18)
                .foregroundStyle(.teal)
                .opacity(0.9)
            
            VStack(alignment: .leading, spacing: 7) {
                Button {
                    showArguments.toggle()
                } label: {
                    HStack {
                        Text("^[\(conversation.toolCalls.count) Tool](inflect: true)")
                            .foregroundStyle(.secondary)
//                            .fontWeight(.semibold)
                        
                        if conversation.isReplying {
                            ProgressView()
                                .controlSize(.mini)
                        } else {
                            Image(systemName: showArguments ? "chevron.up" : "chevron.down")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if showArguments {
                    HStack(alignment: .center) {
                        Rectangle()
                            .fill(.tertiary)
                            .frame(width: 2)
                            .padding(.trailing, 8)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(conversation.toolCalls) { toolCall in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(toolCall.tool.displayName)
                                    Text(toolCall.arguments.prettyPrintJSON())
                                        .foregroundStyle(.secondary)
                                        .textSelection(.enabled)
                                        .monospaced()
                                }
                            }
                        }
                    }
                    .padding(.leading, 4)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    return AssistantMessage(conversation: .mockAssistantTolCallConversation)
        .frame(width: 500, height: 300)
}


