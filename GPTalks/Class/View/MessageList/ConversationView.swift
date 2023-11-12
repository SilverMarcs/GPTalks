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
    let accentColor: Color
    
    let regenHandler: (Conversation) -> Void
    let editHandler: (Conversation) -> Void
    
    @State var isEditing: Bool = false
    @FocusState var isFocused: Bool
    @State var editingMessage: String = ""
    var deleteHandler: (() -> Void)?
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 1) {
            if conversation.role == "user" {
                userMessage
//                    .onHover { hover in
//                        self.isHovered = hover
//                    }

            } else if conversation.role == "assistant" {
                assistantMessage
//                    .onHover { hover in
//                        self.isHovered = hover
//                    }


            } else {
                ReplyingIndicatorView()
                
            }
        }
        #if os(iOS)
        .contextMenu {
            contextMenu
        }
        #endif
    }
    
    @ViewBuilder
    private var userMessage: some View {
        HStack(spacing: 0) {
            Spacer()
            if isEditing {
                editControls()
                TextField("Your edited text here", text: $editingMessage, axis: .vertical)
                    .focused($isFocused)
                    .textFieldStyle(.plain)
                    .bubbleStyle(isMyMessage: true, type: .textEdit)
            } else {
                Menu {
                   contextMenu
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                }
                
                .menuIndicator(.hidden)
                .menuStyle(.borderlessButton)
                .frame(width: 20, height: 20)
                .visible(isHovered)
                
                Text(conversation.content)
                    .textSelection(.enabled)
                    .bubbleStyle(isMyMessage: true, type: .text, accentColor: accentColor)
            }
        }
        .padding(.leading, horizontalPadding)
        .padding(.vertical, 5)
        .padding(.trailing, 15)
        .onHover { hover in
            self.isHovered = hover
        }
    }
    
    @ViewBuilder
    private var assistantMessage: some View {
        HStack(spacing: 2) {
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
            
            Menu {
               contextMenu
            } label: {
                Label("Options", systemImage: "ellipsis.circle")
                    .labelStyle(.iconOnly)
            }
            .menuIndicator(.hidden)
            .menuStyle(.borderlessButton)
            .frame(width: 20, height: 20)
            .visible(isHovered)
            
            Spacer()
        }
        .padding(.trailing, horizontalPadding)
        .padding(.vertical, 5)
        .padding(.leading, 15)
        .onHover { hover in
            self.isHovered = hover
        }
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
    
    @ViewBuilder
    private var contextMenu: some View {
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
    
    private var horizontalPadding: CGFloat {
#if os(iOS)
        return 55
#else
        return 95
#endif
    }
}
