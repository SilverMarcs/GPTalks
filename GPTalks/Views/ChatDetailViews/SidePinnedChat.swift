//
//  SidePinnedChat.swift
//  GPTalks
//
//  Created by Zabir Raihan on 21/11/2024.
//

import SwiftUI

struct SidePinnedChat: View {
    @Environment(ChatVM.self) var chatVM
    var chat: Chat
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            List {
                ForEach(chat.messages, id: \.self) { message in
                    MessageView(message: message)
                }
                .listRowSeparator(.hidden)
            }

            Button {
                chatVM.sidePinnedChat = nil
            } label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SidePinnedChat(chat: .mockChat)
}
