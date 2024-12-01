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
        if message.chat?.currentThread.last == self.message {
            Button(role: .destructive) {
                message.chat?.deleteLastMessage()
            } label: {
                Label("Delete Message", systemImage: "minus.circle")
            }
        }
    }
}
