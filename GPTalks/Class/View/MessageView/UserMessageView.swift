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
        HStack(alignment: .lastTextBaseline, spacing: 4) {
//        VStack {
            Spacer()
            
//            #if os(macOS)
//            Menu {
//                contextMenu
//            } label: {
//                Image(systemName: "ellipsis.circle")
//            }
//            .buttonStyle(.plain)
//            #endif
                        
            Text(conversation.content)
                .textSelection(.enabled)
                .bubbleStyle(isMyMessage: true, accentColor: .accentColor)
        }
        .padding(.trailing, 15)
        .padding(.leading, 105)
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
    
    var contextMenu: some View {
        Group {
            Button {
                editingMessage = conversation.content
                isEditing = true
            } label: {
                Image(systemName: "pencil.tip")
                Text("Edit")
            }
            
            Button {
                conversation.content.copyToPasteboard()
            } label: {
                Image(systemName: "doc")
                Text("Copy")
            }
            
            Button(role: .destructive) {
                session.removeConversation(conversation)
            } label: {
                Image(systemName: "trash")
                Text("Delete")
            }
        }
    }
}
