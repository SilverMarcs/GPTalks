//
//  ContextMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/12/2023.
//

import SwiftUI

struct ContextMenu: View {
    @ObservedObject var session: DialogueSession
    var conversation: Conversation
    var showText: Bool = false
    
    let editHandler: () -> Void
    
    var body: some View {
        Group {
            if conversation.role == "user" {
                Button {
                    editHandler()
                } label: {
                    Image(systemName: "pencil")
                    if showText {
                        Text("Edit")
                    }
                }
            } else {
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
            }

            Button {
                conversation.content.copyToPasteboard()
            } label: {
                Image(systemName: "doc")
                if showText {
                    Text("Copy")
                }
            }

            #if os(macOS)
            Menu {
                extraButtons
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            #else
            Section {
                extraButtons
            }
            #endif
        
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var extraButtons: some View {
        Button {
            session.setResetContextMarker(conversation: conversation)
        } label: {
            Image(systemName: "eraser")
            Text("Reset Context")
        }

        Button(role: .destructive) {
            session.removeConversation(conversation)
        } label: {
            Image(systemName: "trash")
            Text("Delete")
        }
    }
}
