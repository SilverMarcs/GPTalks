//
//  AssistantMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import SwiftUI

struct AssistantMessageView: View {
    @Environment(DialogueViewModel.self) private var viewModel
    var conversation: Conversation
    var session: DialogueSession
    
    @State var isHovered = false
    
    @State var canSelectText = false

    var body: some View {
        Group {
            if AppConfiguration.shared.alternateChatUi {
                alternateUI
            } else {
                originalUI
            }
        }

        #if os(macOS)
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        #else
        .sheet(isPresented: $canSelectText) {
            TextSelectionView(content: conversation.content)
        }
        .contextMenu {
            MessageContextMenu(session: session, conversation: conversation) {}
            toggleTextSelection: {
                canSelectText.toggle()
            }
            .labelStyle(.titleAndIcon)
        }
        #endif
    }
    
    var optionsMenu: some View {
        Menu {
            MessageContextMenu(session: session, conversation: conversation) { }
            toggleTextSelection: {
                canSelectText.toggle()
            }
            .labelStyle(.titleAndIcon)
            
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .buttonStyle(.plain)
        .labelsHidden()
        .menuIndicator(.hidden)
        .opacity(isHovered ? 1 : 0)
        .transition(.opacity)
        .animation(.easeOut(duration: 0.15), value: isHovered)
    }
    
    var alternateUI: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkle")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundColor(Color("niceColorLighter"))
            #if !os(macOS)
                .padding(.top, 3)
            #endif

            VStack(alignment: .leading, spacing: 6) {
                Text("Assistant")
                    .font(.title3)
                    .bold()
                
                Group {
                    if AppConfiguration.shared.isMarkdownEnabled {
                        MarkdownView(text: conversation.content)
                    } else {
                        Text(conversation.content)
                    }
                }
                .textSelection(.enabled)
                
                if conversation.content.isEmpty {
                    ReplyingIndicatorView()
                        .frame(width: 48, height: 16)
                        .padding(.vertical, 10)
                } else {
                    EmptyView()
                }
                
                #if os(macOS)
                if let index = session.conversations.firstIndex(of: conversation) {
                    if let nextConversation = session.conversations[safe: index - 2] {
                        if nextConversation.content == "imageGenerate" {
                            if let toolConversation = session.conversations[safe: index - 1] {
                                ForEach(toolConversation.imagePaths, id: \.self) { imagePath in
                                    if let imageData = getImageData(fromPath: imagePath) {
                                        ImageView(imageData: imageData, imageSize: imageSize, showSaveButton: true)
                                    }
                                }
                            }
                        }
                    }
                }

                // This HStack is moved outside of the conditional blocks to ensure it is always shown.
                HStack {
                    Spacer()
                    
                    messageContextMenu
                }
                #else
                if let index = session.conversations.firstIndex(of: conversation) {
                    if let nextConversation = session.conversations[safe: index - 2] {
                        if nextConversation.content == "imageGenerate" {
                            if let toolConversation = session.conversations[safe: index - 1] {
                                ForEach(toolConversation.imagePaths, id: \.self) { imagePath in
                                    if let imageData = getImageData(fromPath: imagePath) {
                                        ImageView(imageData: imageData, imageSize: imageSize, showSaveButton: true)
                                    }
                                }
                            }
                        }
                    }
                }

                #endif
            }

            Spacer()
        }
        .padding()
        #if os(macOS)
        .padding(.horizontal, 8)
        .padding(.bottom, -5)
        .background(.background.tertiary)
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow : .clear)
        #else
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.1) : .clear)
        .background(.background.secondary)
        #endif
        .animation(.default, value: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText))
        .border(.quinary, width: 1)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    var originalUI: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading) {
                if !conversation.content.isEmpty {
                    if AppConfiguration.shared.isMarkdownEnabled {
                        MarkdownView(text: conversation.content)
                    } else {
                        Text(conversation.content)
                    }
                } else {
                    EmptyView()
                }

                if conversation.isReplying {
                    ReplyingIndicatorView()
                        .frame(width: 48, height: 16)
                } else {
                    EmptyView()
                }
            }
            .bubbleStyle(isMyMessage: false)
            .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow : .clear, in: RoundedRectangle(cornerRadius: radius))
            .textSelection(.enabled)

            #if os(macOS)
            if !conversation.isReplying {
                optionsMenu
            }
            #endif
        }
        .padding(.trailing, horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var messageContextMenu: some View {
        MessageContextMenu(session: session, conversation: conversation) { }
        toggleTextSelection: {
            canSelectText.toggle()
        }
        .labelStyle(.iconOnly)
        .opacity(isHovered ? 1 : 0)
        .transition(.opacity)
        .animation(.easeOut(duration: 0.15), value: isHovered)
    }
    
    @ViewBuilder
    var normalView: some View {
        if let index = session.conversations.firstIndex(of: conversation) {
            if let nextConversation = session.conversations[safe: index - 2] {
                if nextConversation.content == "urlScrape" || nextConversation.content == "imageGenerate" || nextConversation.content == "transcribe" {
                    // Since the next element is also accessed safely, you should safely unwrap it too.
                    if let toolConversation = session.conversations[safe: index - 1] {
                        ToolMessageView(conversation: toolConversation, session: session)
                    }
                }
            }
        }
    }

    private var radius: CGFloat {
        #if os(macOS)
            15
        #else
            18
        #endif
    }
    
    private var horizontalPadding: CGFloat {
        #if os(iOS)
            50
        #else
            65
        #endif
    }
    
    private var imageSize: CGFloat {
        #if os(macOS)
        300
        #else
        325
        #endif
    }
}
