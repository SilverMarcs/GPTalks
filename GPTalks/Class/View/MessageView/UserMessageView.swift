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
    
    @State private var isHovered = false
    @State var isEditing: Bool = false
    @State var editingMessage: String = ""
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(conversation.content)
                .textSelection(.enabled)
                .bubbleStyle(isMyMessage: true, accentColor: session.configuration.provider.accentColor)
        }
        .padding(.vertical, 2)
        .padding(.leading, 95)
        .sheet(isPresented: $isEditing) {
            editingView
        }
        #if os(iOS)
        .contextMenu {
            contextMenu(showText: true)
        }
        #endif
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
    
    func contextMenu(showText: Bool) -> some View {
        HStack(spacing: 12) {
            Button {
                editingMessage = conversation.content
                isEditing = true
            } label: {
                Image(systemName: "pencil")
                if showText {
                    Text("Edit")
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
            
            Button {
                session.setResetContextMarker(conversation: conversation)
            } label: {
                Image(systemName: "eraser")
                if showText {
                    Text("Reset Context")
                }
            }
            
            Button(role: .destructive) {
                session.removeConversation(conversation)
            } label: {
                Image(systemName: "trash")
                if showText {
                    Text("Delete")
                }
            }
        }
        .padding(.trailing)
    }
}
