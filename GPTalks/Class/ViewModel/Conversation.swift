//
//  Conversation.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/3.
//

import SwiftUI
import OpenAI

struct Conversation: Codable, Identifiable, Hashable {
    var id = UUID()
    var date = Date()
    var role: Chat.Role
    var content: String
    var isReplying: Bool = false
    
    func toChat() -> Chat {
        return Chat(role: role, content: content)
    }
}


extension ConversationData {
    
    func sync(with conversation: Conversation) {
        id = conversation.id
        date = conversation.date
        role = conversation.role.rawValue
        content = conversation.content
        do {
            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}

