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

    @Relationship(deleteRule: .cascade)
    var dataFiles: [TypedData] = []
    var role: ConversationRole
    
    @Attribute(.ephemeral)
    var isReplying: Bool = false
    
    var toolCalls: [ToolCall] = []
    var toolResponse: ToolResponse?
    
    init(role: ConversationRole, content: String = "", group: ConversationGroup? = nil, model: AIModel? = nil, dataFiles: [TypedData] = [], toolCalls: [ToolCall] = [], toolResponse: ToolResponse? = nil, isReplying: Bool = false) {
        self.role = role
        self.content = content
        self.group = group
        self.model = model
        self.dataFiles = dataFiles
        self.toolCalls = toolCalls
        self.toolResponse = toolResponse
        self.isReplying = isReplying
    }
    
    var tokenCount: Int {
        let textToken = countTokensFromText(content)
        let toolResponseToken = countTokensFromText(toolResponse?.processedContent ?? "")
        let toolCallTokens = toolCalls.reduce(0) { $0 + countTokensFromText($1.arguments) }
        // TODO: Count image tokens
        return textToken + toolResponseToken + toolCallTokens
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
            toolCalls: toolCalls,
            toolResponse: toolResponse,
            isReplying: isReplying
        )
    }
}

extension Conversation {
    @MainActor
    func setIsReplying(_ value: Bool) {
        self.isReplying = value
    }
    
    @MainActor
    func setContent(_ value: String) {
        self.content = value
    }
    
    @MainActor
    func setToolCalls(_ value: [ToolCall]) {
        self.toolCalls = value
    }
}
