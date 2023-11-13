//
//  ConversationView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/3.
//

import SwiftUI

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
        VStack {
            if conversation.role == "user" {
                userMessage
                    .padding(.trailing, 15)
                    .padding(.leading, horizontalPadding)
            } else if conversation.role == "assistant" {
                assistantMessage
                    .padding(.leading, 15)
                    .padding(.trailing, horizontalPadding)
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
                TextEditor(text: $editingMessage)
                    .font(.body)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                    .frame(maxHeight: 500)
                    .bubbleStyle(isMyMessage: true, type: .edit)
            } else {
                optionsMenu()
                Text(conversation.content)
                    .textSelection(.enabled)
                    .bubbleStyle(isMyMessage: true, type: .text, accentColor: accentColor)
            }
        }
    }

    @ViewBuilder
    private var assistantMessage: some View {
        HStack(alignment: .lastTextBaseline, spacing: 4) {
            VStack(alignment: .leading) {
                if AppConfiguration.shared.isMarkdownEnabled {
                    MessageMarkdownView(text: conversation.content)
                        .textSelection(.enabled)
                }
                if conversation.isReplying {
                    ReplyingIndicatorView()
                        .frame(width: 48, height: 16)
                }
            }
            .bubbleStyle(isMyMessage: false, type: .text)
            if !conversation.isReplying {
                optionsMenu()
            }
            Spacer()
        }
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
            return 45
        #else
            return 85
        #endif
    }
}
