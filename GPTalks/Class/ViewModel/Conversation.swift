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
    var audioPath: String = ""
    var toolRawValue: String = "" // this holds rawValue of tool
    var arguments: String = ""
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

        if chatRole == .assistant, let tool = ChatTool(rawValue: toolRawValue) {
            return .init(role: .assistant, content: "", toolCalls: [.init(id: "", function: .init(arguments: arguments, name: tool.rawValue))])!
        } else if chatRole == .user && !audioPath.isEmpty {
            let audioContent = content + "\n" + audioPath
            return .init(role: chatRole, content: audioContent)!
        } else if chatRole == .tool {
            return .init(role: chatRole, content: content, name: toolRawValue, toolCallId: "")!
        } else if chatRole == .user && !imagePaths.isEmpty {
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
        }
        
        return .init(role: chatRole, content: content)!
    }
}

extension ConversationData {
    func sync(with conversation: Conversation) {
        id = conversation.id
        date = conversation.date
        role = conversation.role
        content = conversation.content
        audioPath = conversation.audioPath
        imagePaths = conversation.imagePaths.joined(separator: "|||")
        toolRawValue = conversation.toolRawValue
        arguments = conversation.arguments
        do {
            try PersistenceController.shared.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

import CoreData

extension Conversation {
    static func createConversationData(from conversation: Conversation, in viewContext: NSManagedObjectContext) -> ConversationData {
        let data = ConversationData(context: viewContext)
        data.id = conversation.id
        data.date = conversation.date
        data.role = conversation.role
        data.content = conversation.content
        data.audioPath = conversation.audioPath
        data.imagePaths = conversation.imagePaths.joined(separator: "|||")
        data.toolRawValue = conversation.toolRawValue
        data.arguments = conversation.arguments
        return data
    }
}
