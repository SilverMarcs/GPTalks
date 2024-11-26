//
//  DeleteButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct DeleteButton: View {
    var message: MessageGroup
    
    var body: some View {
        #if os(macOS)
        Menu {
            if message.allMessages.count > 1 {
                Button("Delete Current Message", role: .destructive) {
                    message.deleteActiveMessage()
                }
            }       
        } label: {
            Image(systemName: "trash")
                .resizable()
                .frame(width: 11, height: 13)
        } primaryAction: {
            message.chat?.deleteMessage(message)
        }
        .help("Delete options")
        #else
        Button(role: .destructive) {
            message.chat?.deleteMessage(message)
        } label: {
            Label("Delete Message", systemImage: "trash")
        }
        #endif
    }
}
