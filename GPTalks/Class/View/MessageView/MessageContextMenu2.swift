//
//  MessageContextMenu2.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/02/2024.
//

import SwiftUI

struct MessageContextMenu2: View {
    @Environment(DialogueViewModel.self) private var viewModel
    var session: DialogueSession
    var conversation: Conversation
    
    let editHandler: () -> Void
    let toggleTextSelection: () -> Void
    
    @State private var itemSize = CGSize.zero
    
    
    var body: some View {
        HStack(spacing: 10) {
            Group {
                if conversation.role == "user" {
                    Button {
                        editHandler()
                    } label: {
                        Image(systemName: "applepencil.tip")
                    }
                }
                
                Button {
                    Task { @MainActor in
                        await session.regenerate(from: conversation)
                    }
                } label: {
                    Image(systemName: "arrow.2.circlepath")
                }
                
                Button {
                    conversation.content.copyToPasteboard()
                } label: {
                    Image(systemName: "paperclip")
                }
                
                Button {
                    session.setResetContextMarker(conversation: conversation)
                } label: {
                    Image(systemName: "eraser")
                }
                
                Button {
                    let forkedConvos = session.forkSession(conversation: conversation)
                    viewModel.addDialogue(conversations: forkedConvos)
                } label: {
                    Image(systemName: "arrow.branch")
                }
                
                Button(role: .destructive) {
                    session.removeConversation(conversation)
                } label: {
                    Image(systemName: "minus.diamond")
                }
                .tint(.red)
                
            }
//            .padding(5)
            .buttonStyle(.plain)
            .imageScale(.medium)
//            .background(.background.secondary)
//            .cornerRadius(4)
        }
    }
}

struct ItemSize: PreferenceKey {
    static var defaultValue: CGSize { .zero }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let next = nextValue()
        value = CGSize(width: max(value.width,next.width),
                       height: max(value.height,next.height))
    }
}
