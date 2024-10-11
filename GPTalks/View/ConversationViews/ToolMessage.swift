//
//  ToolMessage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

struct ToolMessage: View {
    var conversation: Conversation
    @State private var showPopover = false
    
    var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            Rectangle()
                .opacity(0)
                .frame(width: size, height: size)
                
            if !conversation.content.isEmpty {
                Text(conversation.content)
            }
            
            button
                .popover(isPresented: $showPopover, arrowEdge: .leading) {
                    if let toolResponse = conversation.toolResponse {
                        popoverContent(content: toolResponse.processedContent)
                    }
                }
            
            Spacer()
        }
    }
    
    func popoverContent(content: String) -> some View {
        #if os (macOS)
        ScrollView {
            Text(content)
                .textSelection(.enabled)
                .padding()
        }
        .frame(width: 500, height: 400)
        #else
        TextSelectionView(content: content)
        #endif
    }
    
    var button: some View {
        Button(action: { showPopover.toggle() }) {
            GroupBox {
                HStack(spacing: 4) {
                    Text(conversation.isReplying ? "Using" : "Used")
                        .foregroundStyle(.secondary)
                    
                    if let tool = conversation.toolResponse?.tool {
                        Text(tool.displayName)
                            .fontWeight(.semibold)
                        
                        if conversation.isReplying {
                            ProgressView()
                                .controlSize(.mini)
                        } else {
                            Image(systemName: tool.icon)
                        }
                    }
                }
                .padding(3)
            }
        }
        .buttonStyle(.plain)
    }
    
    var size: CGFloat {
        18
    }
    
    var spacing: CGFloat {
        #if os(macOS)
        10
        #else
        7
        #endif
    }
}

#Preview {
    ToolMessage(conversation: .mockToolConversation)
}
