//
//  ToolMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/03/2024.
//

import SwiftUI


// unused
struct ToolMessageView: View {
    var conversation: Conversation
    var session: DialogueSession
    
    @State var showPopover = false
    
    var body: some View {
        Group {
            if conversation.imagePaths.count > 0 {
                HStack {
                    ForEach(conversation.imagePaths, id: \.self) { imagePath in
                        ImageView2(imageUrlPath: imagePath, imageSize: imageSize)
                    }
                }
            } else {
                Button{
                    showPopover.toggle()
                } label: {
                    if let index = session.conversations.firstIndex(of: conversation) {
                        if session.conversations[index - 1].content == "urlScrape" {
                            Text("Web Content")
                        } else if session.conversations[index - 1].content == "transcribe" {
                            Text("Transcription")
                        }
                    }
                }
                .popover(isPresented: $showPopover, arrowEdge: .leading) {
                    ScrollView {
                        Text(conversation.content)
                            .textSelection(.enabled)
                            .padding()
                    }
                    .frame(width: 500, height: 400)
                }
            }
        }
    }
    
    private var imageSize: CGFloat {
        #if os(macOS)
        300
        #else
        325
        #endif
    }
}
