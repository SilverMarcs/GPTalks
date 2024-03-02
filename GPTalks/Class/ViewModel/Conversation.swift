//
//  Conversation.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI
import OpenAI

struct Conversation: Codable, Identifiable, Hashable, Equatable {
    var id = UUID()
    var date = Date()
    var role: String
    var content: String
    var base64Images: [String] = []
    var isReplying: Bool = false
    
    func toChat() -> ChatQuery.ChatCompletionMessageParam {
        let chatRole: ChatQuery.ChatCompletionMessageParam.Role = {
            switch role {
            case "user":
                return .user
            case "assistant":
                return .assistant
            case "system":
                return .system
            default:
                return .tool
            }
        }()
        
        if !base64Images.isEmpty {
            return .init(role: chatRole, content:
                [.init(chatCompletionContentPartTextParam: .init(text: content))] +
                base64Images.map { base64Image in
                    .init(chatCompletionContentPartImageParam: .init(imageUrl: .init(url: ("data:image/jpeg;base64," + base64Image), detail: .auto)))
                }
            )!
        } else {
            return .init(role: chatRole, content: content)!
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

