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
       
                #if os(macOS)
                HStack {
                    
                    Spacer()
                    
                    MessageContextMenu(session: session, conversation: conversation) { } toggleTextSelection: { }
                        .labelStyle(.iconOnly)
                        .opacity(isHovered ? 1 : 0)
                        .transition(.opacity)
                        .animation(.easeOut(duration: 0.15), value: isHovered)
                }
                #endif
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
            .background(Color.gray.opacity(0.12))
//            .background(.background.secondary)
        #endif
//            .border(.quinary, width: 1)
            .border(width: 1, edges: [.top, .leading, .trailing], color: .gray.opacity(0.12))
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .contextMenu {
                MessageContextMenu(session: session, conversation: conversation) { } toggleTextSelection: { }
                .labelStyle(.titleAndIcon)
            }
    }
    
    var funcCall: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Text("Function: " + conversation.content.capitalizingFirstLetter())
                
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
                    } else if conversation.content == "googleSearch" {
                        Image(systemName: "safari")
                    }
                }
            }
            .fontWeight(.semibold)
            .bubbleStyle(isMyMessage: false, sharp: true)
            .onTapGesture {
                if conversation.content != "imageGenerate" {
                    showPopover.toggle()
                }
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
                        .frame(width: 500, height: 400)
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


struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
