//
//  ToolCallView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/03/2024.
//

import SwiftUI

struct ToolCallView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(DialogueViewModel.self) private var viewModel
    
    var conversation: Conversation
    var session: DialogueSession
    
    @State var isHovered = false
    @State var hoverxyz = false
    
    @State var isExpanded = false
    @State var canSelectText = false
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "wrench.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(Color("tealColor"))
#if !os(macOS)
                    .padding(.top, 3)
#endif
            
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tool")
                        .font(.title3)
                        .bold()
                
                    funcCall
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
#if !os(macOS)
        .sheet(isPresented: $canSelectText) {
            TextSelectionView(content: conversation.content)
        }
#endif
        .onHover { isHovered in
            self.isHovered = isHovered
        }
#if os(macOS)
        .padding(.horizontal, 8)
#else
        .contextMenu {
            MessageContextMenu(session: session, conversation: conversation, toggleTextSelection: {
                canSelectText.toggle()
            }, toggleExpanded: {
                isExpanded.toggle()
            })
            .labelStyle(.titleAndIcon)
        }
#endif
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.1) : .clear)
//        .customBorder(width: 1, edges: [.leading, .trailing], color: .gray.opacity(0.12))
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    var messageContextMenu: some View {
        HStack {
            if hoverxyz {
                MessageContextMenu(session: session, conversation: conversation, isExpanded: isExpanded, toggleTextSelection: {
                    canSelectText.toggle()
                }, toggleExpanded: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                })
            } else {
                Image(systemName: "ellipsis")
                    .frame(width: 17, height: 17)
            }
        }
        .contextMenuModifier(isHovered: $isHovered)
    }
    
    var funcCall: some View {
        VStack(alignment: .leading) {
            Button {
                isExpanded.toggle()
            } label: {
                HStack(spacing: 4) {
                    if let tool = ChatTool(rawValue: conversation.toolRawValue) {
                        Text("Used")
                            .foregroundStyle(.secondary)
    
                        Text(tool.toolName)
                            .fontWeight(.semibold)
    
                        if conversation.isReplying {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: tool.systemImageName)
                        }
                    }
                }
                .bubbleStyle(isMyMessage: false, radius: 6)
            }
            .buttonStyle(.plain)
            
            
            if isExpanded {
                Text(conversation.content)
                    .textSelection(.enabled)
                    .padding(.top, 4)
                    .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/, value: isExpanded)
            }
        }
    }
}
