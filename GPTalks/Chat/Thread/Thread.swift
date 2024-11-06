//
//  Thread.swift
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
final class Thread {
    var id: UUID = UUID()
    var date: Date = Date()
    
    var chat: Chat?
    
    @Relationship(deleteRule: .nullify)
    var provider: Provider?
    @Relationship(deleteRule: .nullify)
    var model: AIModel?
    
    var content: String

    @Relationship(deleteRule: .cascade)
    var dataFiles: [TypedData] = []
    var role: ThreadRole
    
    @Attribute(.ephemeral)
    var isReplying: Bool = false
    
    var toolCalls: [ChatToolCall] = []
    var toolResponse: ToolResponse?
    
    init(role: ThreadRole, content: String = "", chat: Chat? = nil, provider: Provider? = nil, model: AIModel? = nil, dataFiles: [TypedData] = [], toolCalls: [ChatToolCall] = [], toolResponse: ToolResponse? = nil, isReplying: Bool = false) {
        self.role = role
        self.content = content
        self.chat = chat
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

    func copy() -> Thread {
        return Thread(
            role: role,
            content: content,
            chat: chat,
            provider: provider,
            model: model,
            dataFiles: dataFiles,
            toolCalls: toolCalls,
            toolResponse: toolResponse,
            isReplying: isReplying
        )
    }
}
