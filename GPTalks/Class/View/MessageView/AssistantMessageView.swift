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
        HStack(alignment: .lastTextBaseline, spacing: 4) {
//        VStack {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .bubbleStyle(isMyMessage: false)
            .textSelection(.enabled)
            
//            #if os(macOS)
//            if !conversation.isReplying {
//                Menu {
//                    contextMenu
//                } label: {
//                    Image(systemName: "ellipsis.circle")
//                }
//                .buttonStyle(.plain)
//            }
//            #endif
        }
        .padding(.leading, 15)
        .padding(.trailing, 105)
#if os(iOS)
        .contextMenu {
            contextMenu
        }
#endif
    }

    var contextMenu: some View {
        Group {
            Button {
                Task { @MainActor in
                    await session.regenerate(from: conversation)
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                Text("Regenerate")
            }
            
            Button {
                conversation.content.copyToPasteboard()
            } label: {
                Image(systemName: "doc")
                Text("Copy")
            }
            
            Button(role: .destructive) {
                session.removeConversation(conversation)
            } label: {
                Image(systemName: "trash")
                Text("Delete")
            }
        }
    }
    
}
