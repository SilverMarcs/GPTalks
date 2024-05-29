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
    var isExpanded: Bool = false
    
    var editHandler: () -> Void = {}
    var toggleTextSelection: () -> Void = {}
    var toggleExpanded: () -> Void = {}
    
    @State private var itemSize = CGSize.zero
    
    
    var body: some View {
        HStack(spacing: 10) {
            Group {
                Section {
                    if conversation.role == .user {
                        #if os(macOS)
                        if conversation.content.count > 300 {
                            expandButton
                        }
                        #endif
                        
                        Button {
                            editHandler()
                        } label: {
                            Label("Edit", systemImage: "applepencil.tip")
                        }
                    } else if conversation.role == .tool {
                        expandButton
                    }
                    
                    if conversation.role != .tool && conversation.arguments.isEmpty {
                        Button {
                            Task { @MainActor in
                                viewModel.moveUpChat(session: session)
                                await session.regenerate(from: conversation)
                            }
                        } label: {
                            Label("Regenerate", systemImage: "arrow.2.circlepath")
                        }
                    }
                    
                    Button {
                        if !conversation.arguments.isEmpty {
                            conversation.arguments.copyToPasteboard()
                        } else {
                            conversation.content.copyToPasteboard()
                        }
                    } label: {
                        Label("Copy", systemImage: "paperclip")
                    }
                    
                    #if !os(macOS)
                    Button {
                        toggleTextSelection()
                    } label: {
                        Label("Select", systemImage: "text.viewfinder")
                    }
                    #endif
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
    
    var expandButton: some View {
        Button {
            toggleExpanded()
        } label: {
            Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
        }
    }
}
