//
//  AssistantMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import SwiftUI

struct AssistantMessageView: View {
    @Environment (\.colorScheme) var colorScheme
    
    @Environment(DialogueViewModel.self) private var viewModel
    var conversation: Conversation
    var session: DialogueSession
    
    @State var isHovered = false
    
    @State var canSelectText = false

    var body: some View {

        alternateUI


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
    
    
    var alternateUI: some View {
        ZStack(alignment: .bottomTrailing) {
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
                    
                    if conversation.isReplying {
                        ReplyingIndicatorView()
                            .frame(width: 48, height: 16)
                            .padding(.vertical, 10)
                    }
                    
                    ForEach(conversation.imagePaths, id: \.self) { imagePath in
                        if let imageData = getImageData(fromPath: imagePath) {
                            ImageView(imageData: imageData, imageSize: imageSize, showSaveButton: true)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
#if os(macOS)
            HStack {
                Spacer()
                
                messageContextMenu
            }
            .padding(10)
            .padding(.horizontal, 8)
#endif
        }
        #if os(macOS)
        .padding(.horizontal, 8)
        .background(.background.tertiary)
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow : .clear)
        #else
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.1) : .clear)
        .background(colorScheme == .dark ? Color.gray.opacity(0.12) : Color.gray.opacity(0.07))
        #endif
        .animation(.default, value: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText))
        .border(.quinary, width: 1)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    
    var messageContextMenu: some View {
        MessageContextMenu(session: session, conversation: conversation) { }
        toggleTextSelection: {
            canSelectText.toggle()
        }
        .contextMenuModifier(isHovered: $isHovered)
    }
    
    private var imageSize: CGFloat {
        #if os(macOS)
        300
        #else
        325
        #endif
    }
}
