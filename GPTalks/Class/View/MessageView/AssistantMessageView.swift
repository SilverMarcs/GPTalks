//
//  AssistantMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import SwiftUI

struct AssistantMessageView: View {
    var conversation: Conversation
    var session: DialogueSession

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading) {
                if AppConfiguration.shared.isMarkdownEnabled {
                    MessageMarkdownView(text: conversation.content)
                } else {
                    Text(conversation.content)
                }
                
                if conversation.isReplying {
                    ReplyingIndicatorView()
                        .frame(width: 48, height: 16)
                }
            }
            //            .frame(maxWidth: .infinity, alignment: .leading)
            .bubbleStyle(isMyMessage: false)
            .textSelection(.enabled)
            
            #if os(macOS)
            if !conversation.isReplying {
            HStack(spacing: 12) {
                contextMenu(showText: false)
                    .buttonStyle(.plain)
                }
            }
            #endif
        }
        .padding(.leading, 15)
        .padding(.trailing, 105)
#if os(iOS)
        .contextMenu {
            contextMenu(showText: true)
        }
#endif
    }

    func contextMenu(showText: Bool) -> some View {
        Group {
            Button {
                Task { @MainActor in
                    await session.regenerate(from: conversation)
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                if showText {
                    Text("Regenerate")
                }
            }
            
            Button {
                conversation.content.copyToPasteboard()
            } label: {
                Image(systemName: "doc")
                if showText {
                    Text("Copy")
                }
            }
            
            Button(role: .destructive) {
                session.removeConversation(conversation)
            } label: {
                Image(systemName: "trash")
                if showText {
                    Text("Delete")
                }
            }
        }
    }
    
}
