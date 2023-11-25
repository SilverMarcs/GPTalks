//
//  ConversationView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/3.
//

import SwiftUI

struct ConversationView: View {
    var conversation: Conversation
    let accentColor: Color

    let regenHandler: (Conversation) -> Void
    let editHandler: (Conversation) -> Void
    let deleteHandler: (() -> Void)?

    @State var isEditing: Bool = false
    @FocusState var isFocused: Bool
    @State var editingMessage: String = ""
    @State private var isHovered = false

    var body: some View {
        VStack {
            if conversation.role == "user" {
                userMessage
            } else if conversation.role == "assistant" {
                assistantMessage
            } else {
                ReplyingIndicatorView()
            }
        }
        .onHover { hover in
            self.isHovered = hover
        }
        .padding(.vertical, 5)
        #if os(iOS)
            .contextMenu {
                contextMenu
            }
        #endif
    }

    @ViewBuilder
    private var userMessage: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Spacer()
            if isEditing {
                editControls()
                #if os(macOS)
                TextEditor(text: $editingMessage)
                    .font(.body)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                    .bubbleStyle(isMyMessage: true, type: .edit)
                    .transition(.opacity)
                #else
                TextField("", text: $editingMessage, axis: .vertical)
                    .lineLimit(5)
                    .bubbleStyle(isMyMessage: true, type: .edit)
                    .transition(.opacity)
                #endif
            } else {
                optionsMenu()
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.15), value: isHovered)
                Text(conversation.content)
                    .textSelection(.enabled)
                    .bubbleStyle(isMyMessage: true, type: .text, accentColor: accentColor)
                    .transition(.opacity)
            }
        }
        .padding(.trailing, 15)
        .padding(.leading, horizontalPadding)
        .animation(.easeInOut, value: isEditing)
    }

    @ViewBuilder
    private var assistantMessage: some View {
        HStack(alignment: .lastTextBaseline, spacing: 4) {
            VStack(alignment: .leading) {
                if !conversation.isReplying && AppConfiguration.shared.isMarkdownEnabled {
                    MessageMarkdownView(text: conversation.content)
                        .textSelection(.enabled)
                } else {
                    if conversation.content.isEmpty {
                        EmptyView()
                    } else {
                        Text(conversation.content)
                            .foregroundColor(.primary)
                            .textSelection(.enabled)
                    }
                }
                if conversation.isReplying {
                    ReplyingIndicatorView()
                        .frame(width: 48, height: 16)
                }
            }
            .bubbleStyle(isMyMessage: false, type: .text)
            
            if !conversation.isReplying {
                optionsMenu()
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.15), value: isHovered)
            }
            Spacer()
        }
        .padding(.leading, 15)
        .padding(.trailing, horizontalPadding)
    }

    @ViewBuilder
    private func optionsMenu() -> some View {
        Menu {
            contextMenu
        } label: {
            Label("Options", systemImage: "ellipsis.circle")
                .labelStyle(.iconOnly)
        }
        .menuIndicator(.hidden)
        .menuStyle(.borderlessButton)
        .frame(width: 20, height: 20)
        .opacity(isHovered ? 1 : 0)
    }

    @ViewBuilder
    func editControls() -> some View {
        HStack(spacing: 15) {
            Button {
                isEditing = false
            } label: {
                Image(systemName: "xmark")
            }
            .keyboardShortcut(.escape, modifiers: .command)
            .buttonStyle(.borderless)
            .foregroundColor(.red)

            Button {
                editHandler(Conversation(role: "user", content: editingMessage))
                isEditing = false
                isFocused = isEditing
            } label: {
                Image(systemName: "checkmark")
            }
            .keyboardShortcut(.return, modifiers: .command)
            .buttonStyle(.borderless)
            .foregroundColor(.green)
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
            return 30
        #else
        if !isEditing {
            return 85
        } else {
            return 70
        }

        #endif
    }
}
