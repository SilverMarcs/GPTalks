//
//  Conversation.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import Foundation
import SwiftData
import OpenAI
import GoogleGenerativeAI
import SwiftAnthropic

@Model
final class Conversation {
    var id: UUID = UUID()
    var date: Date = Date()
    
    var group: ConversationGroup?
    
    @Relationship(deleteRule: .nullify)
    var model: AIModel?
    
    var content: String
//    var imagePaths: [String] = []
    @Attribute(.externalStorage)
    var dataFiles: [TypedData] = []
    var role: ConversationRole
    
    @Attribute(.ephemeral)
    var isReplying: Bool = false
    
    init(role: ConversationRole, content: String, group: ConversationGroup? = nil, model: AIModel? = nil, dataFiles: [TypedData] = [], isReplying: Bool = false) {
        self.role = role
        self.content = content
        self.group = group
        self.model = model
//        self.imagePaths = imagePaths
        self.dataFiles = dataFiles
        self.isReplying = isReplying
    }
    
    func countTokens() -> Int {
        let textToken = countTokensFromText(text: content)
        // TODO: Count image tokens
        return textToken
    }
    
    func deleteSelf() {
        group?.deleteConversation(self)
    }
    
    func copy() -> Conversation {
        return Conversation(
            role: role,
            content: content,
            group: group,
            model: model,
            dataFiles: dataFiles,
            isReplying: isReplying
        )
    }
}
