//
//  ConversationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
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
            optionsMenu()
                .transition(.opacity)
                .animation(.easeOut(duration: 0.15), value: isHovered)
            Text(conversation.content)
                .textSelection(.enabled)
                .bubbleStyle(isMyMessage: true, type: .text, accentColor: accentColor)
        }
        .padding(.trailing, 15)
        .padding(.leading, horizontalPadding)
        .sheet(isPresented: $isEditing) {
            editingView
        }
    }

    var editingView: some View {
        #if os(macOS)
        VStack(spacing: 15) {
            TextEditor(text: $editingMessage)
                .padding(10)
                .font(.body)
                .background(.background.secondary)
                .scrollContentBackground(.hidden)
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(Color.secondary, lineWidth: 0.3)
                
                )
         
            editControls()
        }
        .padding()
        .frame(minWidth: 400, idealWidth: 550, maxWidth: 800, minHeight: 200, idealHeight: 400, maxHeight: 600)
        #else
        NavigationView {
            Form {
                TextField("Editing Message", text: $editingMessage, axis: .vertical)
                    .focused($isFocused)
            }
            .navigationBarTitle("Editing Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) {
                        isEditing = false
                    }
                    .foregroundStyle(.primary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Update") {
                        editHandler(Conversation(role: "user", content: editingMessage))
                        isEditing = false
                        isFocused = isEditing
                    }
                }

            }
        }
        .presentationDetents([.medium])
        #endif
    }
    
    @ViewBuilder
    func editControls() -> some View {
        HStack {
            Button("Cancel") {
                isEditing = false
            }
            .keyboardShortcut(.escape, modifiers: .command)

            Spacer()
            
            Button("Update") {
                editHandler(Conversation(role: "user", content: editingMessage))
                isEditing = false
                isFocused = isEditing
            }
            .keyboardShortcut(.return, modifiers: .command)
        }
    }
    
    @ViewBuilder
    private var assistantMessage: some View {
        HStack(alignment: .lastTextBaseline, spacing: 4) {
            VStack(alignment: .leading) {
                if 
//                    !conversation.isReplying && 
                    AppConfiguration.shared.isMarkdownEnabled {
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
        30
        #else
        85
        #endif
    }
}
