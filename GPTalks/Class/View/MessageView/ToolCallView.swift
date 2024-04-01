//
//  ToolCallView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/03/2024.
//

import SwiftUI

struct ToolCallView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var conversation: Conversation
    var session: DialogueSession
    
    @State var showPopover = false
    @State var isHovered = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
            }
            .padding(10)
            .padding(.horizontal, 8)
#endif
    }
        
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        #if os(macOS)
            .padding(.horizontal, 8)
            .background(.background.secondary)
        #else
            .background(colorScheme == .dark ? Color.gray.opacity(0.12) : Color.gray.opacity(0.07))
        #endif
            .customBorder(width: 1, edges: [.top, .leading, .trailing], color: .gray.opacity(0.12))
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .contextMenu {
                MessageContextMenu(session: session, conversation: conversation) { } toggleTextSelection: { }
                .labelStyle(.titleAndIcon)
            }
    }
    
    var messageContextMenu: some View {
        MessageContextMenu(session: session, conversation: conversation) 
            { }
            toggleTextSelection: { }
        .contextMenuModifier(isHovered: $isHovered)
    }
    
    var funcCall: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Text("Function: " + conversation.content.capitalizingFirstLetter())
                
                if conversation.isReplying {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    if let tool = ChatTool(rawValue: conversation.content) {
                        Image(systemName: tool.systemImageName)
                    }
                }
            }
            .fontWeight(.semibold)
            .bubbleStyle(isMyMessage: false, sharp: true)
            .onTapGesture {
                showPopover.toggle()
            }
            .popover(isPresented: $showPopover, arrowEdge: .leading) {
                if let index = session.conversations.firstIndex(of: conversation) {
                    if let toolMessage = session.conversations[safe: index + 1] {
#if os(macOS)
                        ScrollView {
                            Text(toolMessage.content)
                                .textSelection(.enabled)
                                .padding()
                        }
                        .frame(width: 500, height: conversation.content.count > 80 ? 400 : 200)
#else
                        NavigationView {
                            ScrollView {
                                Text(toolMessage.content)
                                    .padding(.horizontal)
                                    .padding(.bottom, 45)
                            }
                            
                            .edgesIgnoringSafeArea(.bottom)
                            .navigationTitle("Web Conent")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showPopover = false
                                    }
                                }
                            }
                        }
#endif
                    }
                }
            }
            
            if let index = session.conversations.firstIndex(of: conversation) {
                if let toolMessage = session.conversations[safe: index + 1] {
                    if let audioUrl = URL(string:toolMessage.audioPath) {
                        AudioPlayerView(audioURL: audioUrl)
                            .frame(maxWidth: 500)
                    }
                }
            }
        }
    }
}
