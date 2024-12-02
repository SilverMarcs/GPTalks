//
//  ToolCallView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI

struct ToolCallView: View {
    var message: MessageGroup
    @State private var showArguments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label {
                Button {
                    withAnimation {
                        showArguments.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("^[\(message.toolCalls.count) Tool](inflect: true)")
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.secondary)
                            .foregroundStyle(.teal)
                            .brightness(1.1)
                        
                        if message.isReplying {
                            ProgressView()
                                .controlSize(.mini)
                        } else {
                            Image(systemName: showArguments ? "chevron.up" : "chevron.down")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(.secondary)
                                .foregroundStyle(.teal)
                                .brightness(1.1)
                        }
                    }
                    .contentShape(.rect)
                }
                .transaction { $0.animation = nil }
                .buttonStyle(.plain)
            } icon: {
                Image(systemName: "hammer.fill")
                    .imageScale(.medium)
                    .fontWeight(.semibold)
                    .foregroundStyle(.teal)
                    .opacity(0.9)
                    .transaction { $0.animation = nil }
            }
            .padding(.leading, -23)
            
            if !message.content.isEmpty {
                Text(message.content.trimmingCharacters(in: .whitespacesAndNewlines))
                    .lineSpacing(3)
                    .textSelection(.enabled)
                    .transaction { $0.animation = nil }
            }
                
            if showArguments {
                HStack(alignment: .center) {
                    Rectangle()
                        .fill(.tertiary)
                        .frame(width: 2)
                        .padding(.trailing, 8)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(message.toolCalls) { toolCall in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(toolCall.tool.displayName)
                                    .bold()
                                
                                Text(toolCall.arguments)
                                    .foregroundStyle(.secondary)
                                    .textSelection(.enabled)
                                    .monospaced()
                            }
                        }
                    }
                }
                .padding(.leading, 4)
                .padding(.vertical, 8)
            }
        }
        .padding(.leading, 27)
    }
}

#Preview {
    AssistantMessageAux(message: .mockAssistantToolCallGroup)
        .frame(width: 500, height: 300)
}


