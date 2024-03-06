//
//  ToolMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/03/2024.
//

import SwiftUI

struct ToolMessageView: View {
    var conversation: Conversation
    var session: DialogueSession
    
    @State var showPopover = false
    
    var body: some View {
        Group {
            if conversation.imagePaths.count > 0 {
                HStack {
                    ForEach(conversation.imagePaths, id: \.self) { imagePath in
                        if let imageData = getImageData(fromPath: imagePath) {
                            ImageView(imageData: imageData, imageSize: imageSize, showSaveButton: false)
                        }
                    }
                }
            } else {
                Button{
                    showPopover.toggle()
                } label: {
                    Text("Web Content")
                }
                .popover(isPresented: $showPopover, arrowEdge: .leading) {
                    ScrollView {
                        Text(conversation.content)
                            .textSelection(.enabled)
                            .padding()
                    }
                    .frame(width: 600, height: 500)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.background.tertiary)
        .border(.quinary, width: 1)
        
//        Button{
//            showPopover.toggle()
//        } label: {
//            HStack {
//                Text(conversation.role)
//            }
//        }
//        .buttonStyle(.plain)
//        .popover(isPresented: $showPopover, arrowEdge: .leading) {
//            ScrollView {
//                Text(conversation.content)
//                    .padding()
//                
//                ForEach(conversation.imagePaths, id: \.self) { imagePath in
//                    if let imageData = getImageData(fromPath: imagePath) {
//                        ImageView(imageData: imageData, imageSize: imageSize, showSaveButton: false)
//                    }
//                }
//            }
//            .frame(width: 300, height: 200)
//        }
    }
    
    private var imageSize: CGFloat {
        #if os(macOS)
        300
        #else
        325
        #endif
    }
}
