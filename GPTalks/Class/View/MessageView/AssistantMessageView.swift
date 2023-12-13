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
        VStack(alignment: .leading, spacing: 8) {
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
        }
        .padding(.vertical, 2)
        .padding(.leading, 15)
        .padding(.trailing, 95)
        .contextMenu {
            contextMenu(showText: true)
        }
    }

    func contextMenu(showText: Bool) -> some View {
        HStack(spacing: 12) {
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
            
            Button {
                session.setResetContextMarker(conversation: conversation)
            } label: {
                Image(systemName: "eraser")
                if showText {
                    Text("Reset Context")
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
        .padding(.leading)
    }
    
}
