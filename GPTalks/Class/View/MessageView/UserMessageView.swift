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
            Image(systemName: "person.circle.fill") // TODO: Replace with your avatar image
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
                
                if (session.conversations.filter { $0.role == "user" }.last)?.id == conversation.id {
                    editBtn
                }
                
#if os(macOS)
                HStack {
                    Spacer()
                    
                    MessageContextMenu2(session: session, conversation: conversation) {
                        editingMessage = conversation.content
                        isEditing = true
                    } toggleTextSelection: {
                        canSelectText.toggle()
                    }
                }
                .opacity(isHovered ? 1 : 0)
                .transition(.opacity)
                .animation(.easeOut(duration: 0.15), value: isHovered)
                #endif
            }

            Spacer()
        }
        #if os(macOS)
        .padding(.top)
        .padding(.horizontal)
        .padding(.horizontal, 8)
        #else
        .padding()
        #endif
        .frame(maxWidth: .infinity, alignment: .topLeading) // Align content to the top left
    }
    
    var originalUI: some View {
        VStack(alignment: .trailing, spacing: 5) {
            if !conversation.base64Image.isEmpty {
                HStack {
                    Text("Image")
                    Image(systemName: "photo.fill")
                }
                .bubbleStyle(isMyMessage: false, compact: true)
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
            
            HStack(alignment: .lastTextBaseline) {
#if os(macOS)
                optionsMenu
                
                if (session.conversations.filter { $0.role == "user" }.last)?.id == conversation.id {
                    editBtn
                }
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
