//
//  Conversation.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import OpenAI
import SwiftUI
import CoreData

enum ConversationRole: String, Codable, CaseIterable {
    case user
    case assistant
    case system

    func toChatRole() -> ChatQuery.ChatCompletionMessageParam.Role {
        switch self {
        case .user:
            return .user
        case .assistant:
            return .assistant
        case .system:
            return .system
        }
    }
}

import Foundation

@Observable class Conversation: Codable, Identifiable, Hashable, Equatable {
    var id: UUID
    var date: Date
    var role: ConversationRole
    var content: String
    var imagePaths: [String]
    var audioPath: String
    var pdfPath: String
    var toolRawValue: String
    var arguments: String
    var isReplying: Bool

    init(id: UUID = UUID(), date: Date = Date(), role: ConversationRole, content: String, imagePaths: [String] = [], audioPath: String = "", pdfPath: String = "", toolRawValue: String = "", arguments: String = "", isReplying: Bool = false) {
        self.id = id
        self.date = date
        self.role = role
        self.content = content
        self.imagePaths = imagePaths
        self.audioPath = audioPath
        self.pdfPath = pdfPath
        self.toolRawValue = toolRawValue
        self.arguments = arguments
        self.isReplying = isReplying
    }

    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func toChat(imageAsPath: Bool = false) -> ChatQuery.ChatCompletionMessageParam {
        let chatRole = role.toChatRole()

        if chatRole == .user && !audioPath.isEmpty {
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
        role = conversation.role.rawValue
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

extension Conversation {
    static func createConversationData(from conversation: Conversation, in viewContext: NSManagedObjectContext) -> ConversationData {
        let data = ConversationData(context: viewContext)
        data.id = conversation.id
        data.date = conversation.date
        data.role = conversation.role.rawValue
        data.content = conversation.content
        data.audioPath = conversation.audioPath
        data.pdfPath = conversation.pdfPath
        data.imagePaths = conversation.imagePaths.joined(separator: "|||")
        data.toolRawValue = conversation.toolRawValue
        data.arguments = conversation.arguments
        return data
    }
}
