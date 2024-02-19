//
//  UserMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import SwiftUI

struct UserMessageView: View {
    @Environment(DialogueViewModel.self) private var viewModel
    
    var conversation: Conversation
    var session: DialogueSession

    @State var isEditing: Bool = false
    @State var editingMessage: String = ""
    
    @State private var isHovered = false
    
    @State var canSelectText = false
    
    @State var showPreview: Bool = false

    var body: some View {
        Group {
            if AppConfiguration.shared.alternatChatUi {
                alternateUI
            } else {
                originalUI
            }
            
//            if (session.conversations.filter { $0.role == "user" }.last)?.id == conversation.id {
//                editBtn
//            }
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
    
    var alternateUI: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 17, height: 17)
                .foregroundStyle(.secondary)
                #if !os(macOS)
                .padding(.top, 3)
                #endif

            VStack(alignment: .leading, spacing: 6) {
                Text("User")
                    .font(.title3)
                    .bold()
                
                Text(conversation.content)
                    .textSelection(.enabled)
                
                #if !os(macOS)
                if !conversation.base64Image.isEmpty {
                    userImage
                        .bubbleStyle(isMyMessage: false, compact: true)
                }
                #else

                HStack {
                    if !conversation.base64Image.isEmpty {
                        userImage
                            .bubbleStyle(isMyMessage: false, compact: true)
                    }
                    
                    Spacer()
                    
                    MessageContextMenu2(session: session, conversation: conversation) {
                        editingMessage = conversation.content
                        isEditing = true
                    } toggleTextSelection: {
                        canSelectText.toggle()
                    }
                    .opacity(isHovered ? 1 : 0)
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.15), value: isHovered)
                }
                #endif
            }

            Spacer()
        }
        .padding()
        #if os(macOS)
        .padding(.horizontal, 8)
//        .padding(.bottom, -2)
        .padding(.bottom, -6)
        #endif
        .frame(maxWidth: .infinity, alignment: .topLeading) // Align content to the top left
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.1) : .clear)
        .animation(.default, value: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText))
    }
    
    var originalUI: some View {
        VStack(alignment: .trailing, spacing: 5) {
            if !conversation.base64Image.isEmpty {
                userImage
                    .bubbleStyle(isMyMessage: false, compact: true)
            }
            
            HStack(alignment: .lastTextBaseline) {
#if os(macOS)
                optionsMenu
                
#endif
                
                Text(conversation.content)
                    .bubbleStyle(isMyMessage: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? false : true, accentColor: session.configuration.provider.accentColor)
                    .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow : .clear, in: RoundedRectangle(cornerRadius: radius))
                    .textSelection(.enabled)
            }
        }
            .padding(.leading, horizontalPadding)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    var editBtn: some View {
        Button("") {
            editingMessage = conversation.content
            isEditing = true
        }
        .frame(width: 0, height: 0)
        .hidden()
        .keyboardShortcut("e", modifiers: .command)
    }
    
    var userImage: some View {
            HStack {
                Text("Image")
                Image(systemName: "photo.on.rectangle")
            }
            .onTapGesture {
                showPreview = true
            }
            .popover(isPresented: $showPreview) {
#if os(macOS)
                Image(nsImage: NSImage(data: Data(base64Encoded: conversation.base64Image)!)!)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 600, maxHeight: 600, alignment: .center)
                    .presentationCompactAdaptation((.popover))
#else
                Image(uiImage: UIImage(data: Data(base64Encoded: conversation.base64Image)!)!)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 400, maxHeight: 400, alignment: .center)
                    .presentationCompactAdaptation((.popover))
#endif
            }
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
    
    private var horizontalPadding: CGFloat {
        #if os(iOS)
            50
        #else
            65
        #endif
    }
    
    private var radius: CGFloat {
        #if os(macOS)
            15
        #else
            18
        #endif
    }
}
