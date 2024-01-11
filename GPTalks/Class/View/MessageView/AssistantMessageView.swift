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
    
    @State var isHovered = false

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading) {
                if AppConfiguration.shared.isMarkdownEnabled {
                    MarkdownView(text: conversation.content)
                } else {
                    Text(conversation.content)
                }

                if conversation.isReplying {
                    ReplyingIndicatorView()
                        .frame(width: 48, height: 16)
                }
            }
            .bubbleStyle(isMyMessage: false)
            .textSelection(.enabled)

            #if os(macOS)
            if !conversation.isReplying {
                optionsMenu
            }
            #endif
        }
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        .padding(.vertical, 2)
        .padding(.trailing, horizontalPadding)
        #if os(iOS)
            .contextMenu {
                ContextMenu(session: session, conversation: conversation, showText: true) {}
            }
        #endif
    }
    
    var optionsMenu: some View {
        AdaptiveStack(isHorizontal: conversation.content.count < 350) {
           ContextMenu(session: session, conversation: conversation) { }
        }
        .opacity(isHovered ? 1 : 0)
        .transition(.opacity)
        .animation(.easeOut(duration: 0.15), value: isHovered)
    }

    private var horizontalPadding: CGFloat {
        #if os(iOS)
            50
        #else
            65
        #endif
    }
}
