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
    let deleteHandler: (() -> Void)
    let saveHandler: (() -> Void)

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
                contextMenu(showText: true)
            }
        #endif
    }

    @ViewBuilder
    private var userMessage: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Spacer()
            
            #if os(macOS)
            optionsMenu
                .padding(.trailing, 5)
            #endif
            
            Text(conversation.content)
                .textSelection(.enabled)
                .bubbleStyle(isMyMessage: true, accentColor: accentColor)
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
            .bubbleStyle(isMyMessage: false)
            
            #if os(macOS)
            if !conversation.isReplying {
                optionsMenu
                    .padding(.leading, 5)
            }
            #endif
            
            Spacer()
        }
        .padding(.leading, 15)
        .padding(.trailing, horizontalPadding)
    }
    

    var optionsMenu: some View {
        Group {
            if conversation.content.count > 350 {
                VStack(spacing: 10) {
                    contextMenu(showText: false)
                        .buttonStyle(.plain)
                }
            } else {
                HStack(spacing: 10) {
                    contextMenu(showText: false)
                        .buttonStyle(.plain)
                }
            }
        }
        .opacity(isHovered ? 1 : 0)
        .transition(.opacity)
        .animation(.easeOut(duration: 0.15), value: isHovered)
    }

    @ViewBuilder
    func contextMenu(showText: Bool) -> some View {
        Group {
            if conversation.role == "assistant" {
                Button {
                    regenHandler(conversation)
                } label: {
                    Image(systemName: "arrow.clockwise")
                    if showText {
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
                    Image(systemName: "pencil")
                    if showText {
                        Text("Edit")
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
                Button {
                    saveHandler()
                } label: {
                    Image(systemName: conversation.saved ? "bookmark.fill" : "bookmark")
                    Text("Bookmark")
                }
                
                Button(role: .destructive) {
                    deleteHandler()
                } label: {
                    Image(systemName: "eraser")
                    Text("Delete")
                }
                
            } label: {
                Label("Options", systemImage: "ellipsis.circle")
                    .labelStyle(.iconOnly)
            }
            #else
            Button {
                saveHandler()
            } label: {
                Image(systemName: conversation.saved ? "bookmark.fill" : "bookmark")
                Text("Bookmark")
            }
            
            Button(role: .destructive) {
                deleteHandler()
            } label: {
                Image(systemName: "eraser")
                Text("Delete")
            }
            #endif
        }
    }

    private var horizontalPadding: CGFloat {
        #if os(iOS)
        60
        #else
        80
        #endif
    }
}
