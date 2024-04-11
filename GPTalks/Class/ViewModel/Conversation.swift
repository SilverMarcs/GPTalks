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
    var pdfPath: String = ""
    var toolRawValue: String = ""
    var arguments: String = ""
    var isReplying: Bool = false

    func toChat(imageAsPath: Bool = false) -> ChatQuery.ChatCompletionMessageParam {
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
        } else if chatRole == .user && !pdfPath.isEmpty {
            let pdfContent = content + "\n" + pdfPath
            return .init(role: chatRole, content: pdfContent)!
        } else if chatRole == .tool {
            return .init(role: chatRole, content: content, name: toolRawValue, toolCallId: "")!
        } else if chatRole == .assistant && !imagePaths.isEmpty {
            if imageAsPath {
                let imageContent = content + "\n" + imagePaths.joined(separator: "|||")
                return .init(role: chatRole, content: imageContent)!
            } else {
                return createVisionMessage(conversation: self)
            }
        } else if chatRole == .user && !imagePaths.isEmpty {
            if imageAsPath {
                let imageContent = content + "\n" + imagePaths.joined(separator: "|||")
                return .init(role: chatRole, content: imageContent)!
            } else {
                return createVisionMessage(conversation: self)
            }
        }

        return .init(role: chatRole, content: content)!
    }
}

func createVisionMessage(conversation: Conversation) -> ChatQuery.ChatCompletionMessageParam {
    return .init(role: .user,
                 content:
                 [.init(chatCompletionContentPartTextParam: .init(text: conversation.content))] +
                     conversation.imagePaths.map { path in
                         .init(chatCompletionContentPartImageParam:
                             .init(imageUrl:
                                 .init(
                                     url: "data:image/jpeg;base64," + loadImageData(from: path)!.base64EncodedString(),
                                     detail: .auto
                                 )
                             )
                         )
                     })!
}

extension ConversationData {
    func sync(with conversation: Conversation) {
        id = conversation.id
        date = conversation.date
        role = conversation.role
        content = conversation.content
        audioPath = conversation.audioPath
        pdfPath = conversation.pdfPath
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
        data.pdfPath = conversation.pdfPath
        data.imagePaths = conversation.imagePaths.joined(separator: "|||")
        data.toolRawValue = conversation.toolRawValue
        data.arguments = conversation.arguments
        return data
    }
}
