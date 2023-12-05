//
//  Conversation.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
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
        let chatRole: Chat.Role = {
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
    
    func toSavedConversation() -> SavedConversation {
        return SavedConversation(id: UUID(), date: Date(), content: content, title: "Saved")
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

