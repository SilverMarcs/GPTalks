//
//  CopyButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct CopyButton: View {
    var message: MessageGroup
    @State private var isCopied = false
    
    var body: some View {
        Menu {
            Button {
                var finalString = ""
                
                for data in message.dataFiles {
                    finalString += data.formattedTextContent
                }
                
                finalString += message.content
                finalString.copyToPasteboard()
            } label: {
                Label("Copy including file content", systemImage: "doc.doc.on.clipboard")
            }
            
        } label: {
            Label(isCopied ? "Copied" : "Copy Text",
                  systemImage: isCopied ? "checkmark" : "paperclip")
        } primaryAction: {
            message.content.copyToPasteboard() // TODO: copy file sring contents too, use menu here
            isCopied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isCopied = false
            }
        }
        .contentTransition(.symbolEffect(.replace))
        .menuStyle(HoverScaleMenuStyle())
    }
}
