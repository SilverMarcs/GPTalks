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
    var base64Image: String = ""
    var isReplying: Bool = false
    
    func toChat() -> Message {
        let chatRole: Message.Role = {
            switch role {
            case "user":
                return Message.Role.user
            case "assistant":
                return Message.Role.assistant
            case "system":
                return Message.Role.system
            default:
                return Message.Role.function
            }
        }()
        
        if !base64Image.isEmpty {
            return Message(role: chatRole, content: [ChatContent(type: .text, value: content), ChatContent(type: .imageUrl, value: "data:image/jpeg;base64," + base64Image)])
        } else {
            return Message(role: chatRole, content: [ChatContent(type: .text, value: content)])
        }
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

