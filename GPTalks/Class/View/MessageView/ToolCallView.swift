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
    
    @Environment(\.dismiss) var dismiss
    
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
            .background(.background.secondary)
        #endif
            .border(.quinary, width: 1)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .contextMenu {
                MessageContextMenu(session: session, conversation: conversation) { } toggleTextSelection: { }
                .labelStyle(.titleAndIcon)
            }
    }
    
    var funcCall: some View {
        HStack(spacing: 4) {
            
//            if isAudioFile(urlString: "file:///Users/Zabir/Downloads/test.mp3") {
//                AudioPlayerView(audioURL: URL(fileURLWithPath: "file:///Users/Zabir/Downloads/test.mp3"))
//            }
//            AudioPlayerView(audioURL: URL(string: "file:///Users/Zabir/Downloads/test.mp3")!)
            
            Text("Function: " + conversation.content.capitalizingFirstLetter())
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
                                            dismiss()
                                        }
                                    }
                                }
                            }
                            #endif
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
    
    func isAudioFile(urlString: String) -> Bool {
         guard let url = URL(string: urlString) else { return false }

         // Determine the file's Uniform Type Identifier (UTI)
         guard let uti = try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else { return false }

         // Popular audio UTIs
         let audioTypes = [
             "public.mp3",
             "public.mpeg-4",
             "public.aiff-audio",
             "com.apple.coreaudio-format",
             "public.audiovisual-content"
             // Add more audio types if needed
         ]

         return audioTypes.contains(uti)
     }
}

