//
//  Message.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import Foundation
import SwiftData

@Model
final class Message {
    var id: UUID = UUID()
    var date: Date = Date()
    
    @Relationship(deleteRule: .nullify)
    var provider: Provider?
    @Relationship(deleteRule: .nullify)
    var model: AIModel?
    
    var content: String

    @Relationship(deleteRule: .cascade)
    var dataFiles: [TypedData] = []
    var role: MessageRole
    
    @Attribute(.ephemeral)
    var isReplying: Bool = false
    
    var toolCalls: [ChatToolCall] = []
    var toolResponse: ToolResponse?
    
    init(role: MessageRole, content: String = "", provider: Provider? = nil, model: AIModel? = nil, dataFiles: [TypedData] = [], toolCalls: [ChatToolCall] = [], toolResponse: ToolResponse? = nil, isReplying: Bool = false) {
        self.role = role
        self.content = content
        self.provider = provider
        self.model = model
        self.dataFiles = dataFiles
        self.toolCalls = toolCalls
        self.toolResponse = toolResponse
        self.isReplying = isReplying
    }
    
    init(toolResponse: ToolResponse) {
        self.role = .tool
        self.content = ""
        self.toolResponse = toolResponse
        self.isReplying = true
    }

    func copy() -> Message {
        return Message(
            role: role,
            content: content,
            provider: provider,
            model: model,
            dataFiles: dataFiles,
            toolCalls: toolCalls,
            toolResponse: toolResponse,
            isReplying: isReplying
        )
    }
}
