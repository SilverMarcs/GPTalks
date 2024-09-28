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
    let codeBlock = """
    This is a code block
    
    ```swift
    struct ContentView: View {
        var body: some View {
            Text("Hello, World!")
        }
    }
    ```
    
    Thank you for using me.
    
    """
    let providers: [Provider] = []
    let toolResponse: ToolResponse = .init(toolCallId: "", tool: .urlScrape, processedContent: codeBlock)
    let conversation = Conversation(role: .tool,
                                    toolResponse: toolResponse)
    conversation.isReplying = true
    
    return AssistantMessage(conversation: conversation)
        .frame(width: 500, height: 300)
}


