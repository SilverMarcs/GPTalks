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
        Button {
            message.content.copyToPasteboard()
            isCopied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isCopied = false
            }
        } label: {
            Label("Copy", systemImage: "doc.on.clipboard")
        }
        
        if !message.dataFiles.isEmpty {
            Button {
                var finalString = ""
                
                for data in message.dataFiles {
                    finalString += data.formattedTextContent
                }
                
                finalString += message.content
                finalString.copyToPasteboard()
            } label: {
                Label("Copy files", systemImage: "doc.richtext")
            }
        }
    }
}
