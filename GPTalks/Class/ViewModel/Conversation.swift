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
//    var audioPath: String = ""
//    var imagePrompt: String = ""
//    var webUrl: String = ""
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
            case "tool":
                return .tool
            default:
                return .user
            }
        }()

        if chatRole != .tool {
            if chatRole == .assistant && content == "urlScrape" {
                return .init(role: .assistant, content: "", toolCalls: [.init(id: "", function: .init(arguments: "webFuncParam", name: "urlScrape"))])!
            } else if chatRole == .assistant && content == "imageGenerate" {
                return .init(role: .assistant, content: "", toolCalls: [.init(id: "", function: .init(arguments: "prompt", name: "imageGenerate"))])!
            } else if chatRole == .assistant && content == "transcribe" {
                return .init(role: .assistant, content: "", toolCalls: [.init(id: "", function: .init(arguments: "audioPath", name: "transcribe"))])!
            } else {
                if !imagePaths.isEmpty {
                    return .init(role: chatRole, content:
                                    [.init(chatCompletionContentPartTextParam: .init(text: content))] +
                                 imagePaths.map { path in
                            .init(chatCompletionContentPartImageParam:
                                    .init(imageUrl:
                                            .init(
                                                url: "data:image/jpeg;base64," +
                                                (getSavedImage(fromPath: path)!
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
        } else {
            if content == "imageGenerate" {
                return .init(role: .tool, content: content, name: "imageGenerate", toolCallId: "")!
            } else if content == "transcribe" {
                return .init(role: .tool, content: content, name: "transcribe", toolCallId: "")!
            } else {
                return .init(role: .tool, content: content, name: "urlScrape", toolCallId: "")!
            }
            
//            return .init(role: .tool, content: content, name: "urlScrape", toolCallId: "")!
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
