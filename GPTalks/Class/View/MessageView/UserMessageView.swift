//
//  UserMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import SwiftUI

struct UserMessageView: View {
    var conversation: Conversation
    var session: DialogueSession

    @State var isEditing: Bool = false
    @State var editingMessage: String = ""
    
    @State private var isHovered = false

    var body: some View {
        let lastUserMessage = session.conversations.filter{ $0.role == "user" }.last
        
        HStack(alignment: .lastTextBaseline) {
#if os(macOS)
            optionsMenu
            
            if lastUserMessage?.id == conversation.id {
                Button("") {
                    editingMessage = conversation.content
                    isEditing = true
                }
                .frame(width: 0, height: 0)
                .hidden()
                .keyboardShortcut("e", modifiers: .command)
            }
#endif
            
            Text(conversation.content)
                .textSelection(.enabled)
                .bubbleStyle(isMyMessage: true, accentColor: session.configuration.provider.accentColor)

        }
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        .padding(.vertical, 2)
        .padding(.leading, horizontalPadding)
        .sheet(isPresented: $isEditing) {
            editingView
        }
        #if os(iOS)
        .contextMenu {
            MessageContextMenu(session: session, conversation: conversation, showText: true) {
                editingMessage = conversation.content
                isEditing = true
            }
        }
        #endif
    }
    
    var optionsMenu: some View {
        AdaptiveStack(isHorizontal: conversation.content.count < 350) {
            MessageContextMenu(session: session, conversation: conversation) {
                    editingMessage = conversation.content
                    isEditing = true
                }

        }
        .opacity(isHovered ? 1 : 0)
        .transition(.opacity)
        .animation(.easeOut(duration: 0.15), value: isHovered)
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

                editControls
            }
            .padding()
            .frame(minWidth: 400, idealWidth: 550, maxWidth: 800, minHeight: 200, idealHeight: 400, maxHeight: 600)
        #else
            NavigationView {
                Form {
                    TextField("Editing Message", text: $editingMessage, axis: .vertical)
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
                            Task { @MainActor in
                                await session.edit(conversation: conversation, editedContent: editingMessage)
                            }
                            isEditing = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        #endif
    }

    var editControls: some View {
        HStack {
            Button("Cancel") {
                isEditing = false
            }
            .keyboardShortcut(.escape, modifiers: .command)

            Spacer()

            Button("Update") {
                Task { @MainActor in
                    await session.edit(conversation: conversation, editedContent: editingMessage)
                }
                isEditing = false
            }
            .keyboardShortcut(.return, modifiers: .command)
        }
    }

    private var horizontalPadding: CGFloat {
        #if os(iOS)
            50
        #else
        65
        #endif
    }
}
