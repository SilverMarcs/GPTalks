//
//  EmptyChat.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/09/2024.
//

import SwiftUI

struct EmptyChat: View {
    @Bindable var chat: Chat
    
    var body: some View {
        Image(chat.config.provider.type.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundStyle(.quaternary)
            .fullScreenBackground()
    }
}

#Preview {
    EmptyChat(chat: .mockChat)
}
