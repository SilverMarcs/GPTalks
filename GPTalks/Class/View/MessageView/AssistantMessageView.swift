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
    
    @State var canSelectText = false

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading) {
                if !conversation.content.isEmpty {
                    if AppConfiguration.shared.isMarkdownEnabled {
                        MarkdownView(text: conversation.content)
                    } else {
                        Text(conversation.content)
                    }
                } else {
                    EmptyView()
                }

                if conversation.isReplying {
                    ReplyingIndicatorView()
                        .frame(width: 48, height: 16)
                } else {
                    EmptyView()
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
#if os(iOS)
        .sheet(isPresented: $canSelectText) {
            TextSelectionView(content: conversation.content)
        }
#endif
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        #if os(iOS)
            .contextMenu {
                MessageContextMenu(session: session, conversation: conversation, showText: true) {}
                toggleTextSelection: {
                    canSelectText.toggle()
                }
            }
        #endif
    }
    
    var optionsMenu: some View {
        AdaptiveStack(isHorizontal: conversation.content.count < 350) {
            MessageContextMenu(session: session, conversation: conversation) { }
            toggleTextSelection: {
                canSelectText.toggle()
            }
            
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
