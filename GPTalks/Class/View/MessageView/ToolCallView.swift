//
//  ToolCallView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/03/2024.
//

import SwiftUI

struct ToolCallView: View {
    var conversation: Conversation
    var session: DialogueSession
    
    @State var showPopover = false
    @State var isHovered = false
    
    var body: some View {
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
       
                HStack {
                    
                    Spacer()
                    
                    MessageContextMenu(session: session, conversation: conversation) { } toggleTextSelection: {}
                        .labelStyle(.iconOnly)
                        .opacity(isHovered ? 1 : 0)
                        .transition(.opacity)
                        .animation(.easeOut(duration: 0.15), value: isHovered)
                    }
                
                }
            
            Spacer()
        }
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        .padding()
        #if os(macOS)
            .padding(.horizontal, 8)
            .padding(.bottom, -5)
            .background(.background.secondary)
        #else
            .background(.background.tertiary)
        #endif
            .border(.quinary, width: 1)
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    var funcCall: some View {
        HStack(spacing: 4) {
            Text("Function: " + conversation.content.capitalizingFirstLetter())
                .onTapGesture {
                    if conversation.content != "imageGenerate" {
                        showPopover.toggle()
                    }
                }
                .popover(isPresented: $showPopover, arrowEdge: .leading) {
                    if let index = session.conversations.firstIndex(of: conversation) {
                        if let toolMessage = session.conversations[safe: index + 1] {
                            ScrollView {
                                Text(toolMessage.content)
                                    .textSelection(.enabled)
                                    .padding()
                            }
                            .frame(width: 500, height: 400)
                        }
                    }
                }
            
            if conversation.isReplying {
                ProgressView()
                    .controlSize(.small)
            } else {
                if conversation.content == "urlScrape" {
                    Image(systemName: "network")
                } else if conversation.content == "transcribe" {
                    Image(systemName: "waveform")
                } else if conversation.content == "imageGenerate" {
                    Image(systemName: "photo")
                }
            }
        }
        .fontWeight(.semibold)
        .bubbleStyle(isMyMessage: false)
    }
}
