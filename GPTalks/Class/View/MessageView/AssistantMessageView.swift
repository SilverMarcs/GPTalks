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
    @State var hoverxyz = false
    
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
            MessageContextMenu(session: session, conversation: conversation,
            toggleTextSelection: {
                canSelectText.toggle()
            })
            .labelStyle(.titleAndIcon)
        }
        #endif
    }
    
    
    var alternateUI: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(Color("niceColorLighter"))
#if !os(macOS)
                    .padding(.top, 3)
#else
                    .offset(y: 1)
#endif
                
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Assistant")
                            .font(.title3)
                        
                        if let _ = ChatTool(rawValue: conversation.toolRawValue) {
                            Text("Tool Call")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 11))
                        }
                    }
                    
                    Group {
                        if let _ = ChatTool(rawValue: conversation.toolRawValue) {
                            Text(conversation.arguments)
//                                .textSelection(.enabled)
                        } else {
//                            Group {
                                if AppConfiguration.shared.isMarkdownEnabled {
                                    MessageMarkdownView(text: conversation.content)
                                } else {
                                    Text(conversation.content)
                                }
//                            }

                        }
                    }
                    .textSelection(.enabled)
                    
                    if conversation.isReplying {
                        ProgressView()
                            .controlSize(.small)
                    }
                    
                    ForEach(conversation.imagePaths, id: \.self) { imagePath in
                        ImageView2(imageUrlPath: imagePath, imageSize: imageSize, showSaveButton: true)
                    }
                }
                
                Spacer()
            }
            .padding()
#if os(macOS)
            HStack {
                Spacer()
                
                messageContextMenu
                    .padding(.leading, 200) // Increase padding to enlarge the invisible hover area
  //                  .background(Color.blue.opacity(0.1)) // Optional: Just to visualize the area during development
                    .contentShape(Rectangle()) // Make the whole padded area hoverable
                    .onHover { isHovered in
                        hoverxyz = isHovered
                    }
                    .animation(.easeInOut(duration: 0.15), value: hoverxyz)
            }
//            .padding(10)
            .padding(.top, -40)
            .padding(.bottom, 3)
            .padding(.horizontal, 18)
#endif
        }
        #if os(macOS)
        .padding(.horizontal, 8)
        .background(.background.tertiary)
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.4) : .clear)
        #else
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.1) : .clear)
        .background(colorScheme == .dark ? Color.gray.opacity(0.12) : Color.gray.opacity(0.07))
        #endif
        .animation(.default, value: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText))
        .border(.quinary, width: 1)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    var messageContextMenu: some View {
        HStack {
            if hoverxyz {
                MessageContextMenu(session: session, conversation: conversation,
                                   toggleTextSelection: { canSelectText.toggle() })
            } else {
                Image(systemName: "ellipsis")
                    .frame(width: 17, height: 17)
            }
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
