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
            Label(isCopied ? "Copied" : "Copy Text", 
                  systemImage: isCopied ? "checkmark" : "paperclip")
        }
        .frame(width: 10)
        .contentTransition(.symbolEffect(.replace))
    }
}
