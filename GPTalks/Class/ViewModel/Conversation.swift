//
//  Conversation.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import OpenAI
import SwiftUI

struct Conversation: Codable, Identifiable, Hashable, Equatable {
    var id = UUID()
    var date = Date()
    var role: String
    var content: String
    var imagePaths: [String] = []
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

        if !imagePaths.isEmpty {
            return .init(role: chatRole, content:
                [.init(chatCompletionContentPartTextParam: .init(text: content))] +
                         imagePaths.map { base64Image in
                        .init(chatCompletionContentPartImageParam:
                            .init(imageUrl:
                                .init(
                                    url: "data:image/jpeg;base64," + 
                                        (getSavedImage(fromPath: base64Image)!
                                            .base64EncodedString())!,
                                    detail: .auto
                                )
                            )
                        )
                    })!
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
        } catch {
            print(error.localizedDescription)
        }
    }
}
