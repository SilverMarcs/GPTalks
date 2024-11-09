//
//  ToolCallView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI

struct ToolCallView: View {
    var thread: Thread
    @State private var showArguments = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "hammer")
                .resizable()
                .fontWeight(.semibold)
                .frame(width: 18, height: 18)
                .foregroundStyle(.teal)
                .opacity(0.9)
                .transaction { $0.animation = nil }
            
            VStack(alignment: .leading, spacing: 5) {
                Button {
                    withAnimation {
                        showArguments.toggle()
                    }
                } label: {
                    HStack {
                        Text("^[\(thread.toolCalls.count) Tool](inflect: true)")
                            .foregroundStyle(.secondary)
                        
                        if thread.isReplying {
                            ProgressView()
                                .controlSize(.mini)
                        } else {
                            Image(systemName: showArguments ? "chevron.up" : "chevron.down")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .transaction { $0.animation = nil }
                .buttonStyle(.plain)
                
                if !thread.content.isEmpty {
                    Text(thread.content)
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
                            ForEach(thread.toolCalls) { toolCall in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(toolCall.tool.displayName)
                                    Text(toolCall.arguments)
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
        }
    }
}

#Preview {
    AssistantMessage(thread: .mockAssistantTolCallThread)
        .frame(width: 500, height: 300)
}

