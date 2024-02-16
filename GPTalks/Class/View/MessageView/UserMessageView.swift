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
    
    @State var canSelectText = false

    var body: some View {
        let lastUserMessage = session.conversations.filter { $0.role == "user" }.last
        
        VStack(alignment: .trailing, spacing: 11) {
            if !conversation.base64Image.isEmpty {
#if os(macOS)
                    Image(nsImage: NSImage(data: Data(base64Encoded: conversation.base64Image)!)!)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 400, maxHeight: 350, alignment: .center)
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(10)
                        .padding(.trailing, 2)
                        .padding(.top, -4)
#else
                    Image(uiImage: UIImage(data: Data(base64Encoded: conversation.base64Image)!)!)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 400, maxHeight: 350, alignment: .center)
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(10)
                        .padding(.trailing, 2)
                        .padding(.top, -4)
#endif
            }
                
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
        }
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        .sheet(isPresented: $isEditing) {
            EditingView(editingMessage: $editingMessage, isEditing: $isEditing, session: session, conversation: conversation)
        }
        #if os(iOS)
        .sheet(isPresented: $canSelectText) {
            TextSelectionView(content: conversation.content)
        }
        .contextMenu {
            MessageContextMenu(session: session, conversation: conversation, showText: true) {
                editingMessage = conversation.content
                isEditing = true
            } toggleTextSelection: {
                canSelectText.toggle()
            }
        }
        #endif
    }
    
    var optionsMenu: some View {
        AdaptiveStack(isHorizontal: conversation.content.count < 350) {
            MessageContextMenu(session: session, conversation: conversation) {
                editingMessage = conversation.content
                isEditing = true
            } toggleTextSelection: {
                canSelectText.toggle()
            }
        }
        .opacity(isHovered ? 1 : 0)
        .transition(.opacity)
        .animation(.easeOut(duration: 0.15), value: isHovered)
    }
}
