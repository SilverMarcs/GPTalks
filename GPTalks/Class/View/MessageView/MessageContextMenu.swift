//
//  MessageContextMenu2.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/02/2024.
//

import SwiftUI

struct MessageContextMenu: View {
    @Environment(DialogueViewModel.self) private var viewModel
    var session: DialogueSession
    var conversation: Conversation
    
    let editHandler: () -> Void
    let toggleTextSelection: () -> Void
    
    @State private var itemSize = CGSize.zero
    
    
    var body: some View {
        HStack(spacing: 10) {
            Group {
                Section {
                    if conversation.role == "user" {
                        Button {
                            editHandler()
                        } label: {
                            Label("Edit", systemImage: "applepencil.tip")
                        }
                    }
                    
                    Button {
                        Task { @MainActor in
                            await session.regenerate(from: conversation)
                        }
                    } label: {
                        Label("Regenerate", systemImage: "arrow.2.circlepath")
                    }
                    
                    Button {
                        conversation.content.copyToPasteboard()
                    } label: {
                        Label("Copy", systemImage: "paperclip")
                    }
                }
                
                Section {
                    Button {
                        session.setResetContextMarker(conversation: conversation)
                    } label: {
                        Label("Reset Cntext", systemImage: "eraser")
                    }
                    
                    Button {
                        let forkedConvos = session.forkSession(conversation: conversation)
                        viewModel.addDialogue(conversations: forkedConvos)
                    } label: {
                        Label("Fork Session", systemImage: "arrow.branch")
                    }
                }
                
                Section {
                    
                    Button(role: .destructive) {
                        session.removeConversation(conversation)
                    } label: {
                        Label("Delete Message", systemImage: "minus.diamond")
                    }
                    .tint(.red)
                    
                }
            }
            .buttonStyle(.plain)
            .imageScale(.medium)
        }
    }
}
