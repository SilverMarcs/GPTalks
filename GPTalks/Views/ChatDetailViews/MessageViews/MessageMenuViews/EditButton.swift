//
//  EditButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct EditButton: View {
    @Environment(\.isQuick) var isQuick
    var message: MessageGroup
    
    var body: some View {
        if !isQuick && message.role == .user {
            Button {
                message.chat?.inputManager.setupEditing(message: message)
            } label: {
                Label("Edit", systemImage: "pencil.and.outline")
            }
            .help("Edit")
        }
    }
}
