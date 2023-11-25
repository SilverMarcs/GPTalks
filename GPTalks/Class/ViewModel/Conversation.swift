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
    var role: String
    var content: String
    var isReplying: Bool = false
    
    func toChat() -> Chat {
        var chatRole: Chat.Role = {
            switch role {
            case "user":
                return Chat.Role.user
            case "assistant":
                return Chat.Role.assistant
            case "system":
                return Chat.Role.system
            default:
                return Chat.Role.function
            }
        }()
        
        return Chat(role: chatRole, content: content)
    }
}

extension ConversationData {
    
    func sync(with conversation: Conversation) {
        id = conversation.id
        date = conversation.date
        role = conversation.role
        content = conversation.content
        do {
            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}

