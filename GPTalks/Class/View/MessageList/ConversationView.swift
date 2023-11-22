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
    let deleteHandler: (() -> Void)?

    @State var isEditing: Bool = false
    @FocusState var isFocused: Bool
    @State var editingMessage: String = ""
    @State private var isHovered = false
    @State private var showPopover = false
    
    let maxHeight: CGFloat = 500
    private var exceedsMaxHeight: Bool {
        conversation.content.count > 1200 || editingMessage.count > 1200
    }
    

    var body: some View {
        VStack {
            if conversation.role == .user {
                VStack(alignment: .trailing) {
                    userMessage
                    
                    if (exceedsMaxHeight) {
                        Button("Show More") {
                            showPopover = true
                        }
                        .clipShape(.capsule(style: .circular))
                        .opacity(isEditing ? 0 : 1)
                        .popover(isPresented: $showPopover) {
                            ScrollView {
                                Text(conversation.content)
                            }
                            .frame(maxWidth: 400, maxHeight: 400)
                            .padding(10)
                        }
                    }
                }
//                .frame(maxHeight: exceedsMaxHeight ? maxHeight : .infinity)  // TODO: v bad
                .padding(.trailing, 15)
                .padding(.leading, horizontalPadding)
            } else if conversation.role == .assistant {
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
                    .frame(maxHeight: exceedsMaxHeight ? maxHeight : .infinity)  // TODO: v bad
                    .padding(.vertical, exceedsMaxHeight ? 1.5 : 0)
                    .font(.body)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                    .bubbleStyle(isMyMessage: true, type: .edit)
                    .transition(.opacity)
            } else {
                optionsMenu()
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.15), value: isHovered)
                Text(conversation.content)
                    .frame(maxHeight: exceedsMaxHeight ? maxHeight : .infinity)  // TODO: v bad
                    .textSelection(.enabled)
                    .bubbleStyle(isMyMessage: true, type: .text, accentColor: accentColor)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: isEditing)
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
                editHandler(Conversation(role: .user, content: editingMessage))
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
        if conversation.role == .assistant {
            Button {
                regenHandler(conversation)
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Regenerate")
                }
            }
        }
        if conversation.role == .user {
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
        if !isEditing {
            return 85
        } else {
            return 54
        }

        #endif
    }
}
