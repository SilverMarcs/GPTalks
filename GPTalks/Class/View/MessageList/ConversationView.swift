//
//  ConversationView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/3.
//

import SwiftUI
import SwiftUIX

struct ConversationView: View {
    
    let conversation: Conversation
    let service: AIProvider
    
    let regenHandler: (Conversation) -> Void
    let editHandler: (Conversation) -> Void
    
    @State var isEditing = false
    @FocusState var isFocused: Bool
    @State var editingMessage: String = ""
    var deleteHandler: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            if conversation.role == "user" {
                userMessage

            } else if conversation.role == "assistant" {
                assistantMessage

            } else {
                ReplyingIndicatorView()
                
            }
        }
//        .padding(.horizontal, 15)
        
        .contextMenu {
            if conversation.role == "assistant" {
                Button {
                    regenHandler(conversation)
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Regenerate")
                    }
                }
            }
            if conversation.role == "user" {
                Button {
                    editingMessage = conversation.content
                    isEditing = true
                    isFocused = true
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                }
            }
            Button {
                conversation.content.copyToPasteboard()
            } label: {
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Copy")
                }
            }
            Button(role: .destructive) {
                deleteHandler?()
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
        }
    }
    
    var userMessage: some View {
        HStack(spacing: 0) {
            Spacer()
            if isEditing {
                editControls()
                TextField("Your edited text here", text: $editingMessage, axis: .vertical)
                    .focused($isFocused)
                    .textFieldStyle(.plain)
                    .bubbleStyle(isMyMessage: true, type: .textEdit)
            } else {
                Text(conversation.content)
                    .textSelection(.enabled)
                    .bubbleStyle(isMyMessage: true, type: .text, service: service)
            }
        }
        .padding(.leading, horizontalPadding)
        .padding(.vertical, 5)
        .padding(.trailing, 15)
    }
    
    var assistantMessage: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                if AppConfiguration.shared.isMarkdownEnabled{
                    MessageMarkdownView(text: conversation.content)
                        .textSelection(.enabled)
                }
                
                if conversation.isReplying {
                    ReplyingIndicatorView()
                        .frame(width: 48, height: 16)
                }
            }
            .bubbleStyle(isMyMessage: false, type: .text)
            
            Spacer()
        }
        .padding(.trailing, horizontalPadding)
        .padding(.vertical, 5)
        .padding(.leading, 15)
    }
    
    
    @ViewBuilder
    func editControls() -> some View {
        HStack(spacing: 15) {
            Button {
                isEditing = false
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.borderless)
            .foregroundColor(.red)
            
            Button {
                editHandler(Conversation(role: "user", content: editingMessage))
                isEditing = false
                isFocused = isEditing
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.borderless)
            .foregroundColor(.green)
            .keyboardShortcut(isEditing ? .defaultAction : .none)
            
        }
        .padding(.trailing, 10)
    }
    
    private var horizontalPadding: CGFloat {
#if os(iOS)
        return 55
#else
        return 105
#endif
    }
}
