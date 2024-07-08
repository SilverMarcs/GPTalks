//
//  UserMessage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct UserMessage: View {
    var conversation: Conversation
    @State var isHovered: Bool = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(conversation.content)
                .textSelection(.enabled)
                .padding(.vertical, 9)
                .padding(.horizontal, 11)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.background.quinary)
                )
            
            if let group = conversation.group {
                ConversationMenu(group: group)
                    .opacity(isHovered ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isHovered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.leading, 160)
        .onHover { isHovered in
            self.isHovered = isHovered
        }
    }
}

#Preview {
    let conversation = Conversation(
        role: .user, content: "Hello, World! who are you and how are you")

    UserMessage(conversation: conversation)
        .frame(width: 500, height: 300)
}
