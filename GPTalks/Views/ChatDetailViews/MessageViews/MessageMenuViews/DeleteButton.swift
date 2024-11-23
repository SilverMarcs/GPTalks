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
        Button(role: .destructive) {
            message.chat?.deleteMessage(message)
        } label: {
            #if os(macOS)
            Image(systemName: "trash")
                .resizable()
                .frame(width: 11, height: 13)
            #else
            Label("Delete", systemImage: "trash")
            #endif
        }
        .help("Delete")
    }
}
