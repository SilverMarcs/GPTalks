//
//  StreamHandler.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import Foundation
import SwiftUI

struct StreamHandler {
    private let chat: Chat
    private var assistant: Message // TODO: maybe need ot fidn diff way of getting setting assistant

    init(chat: Chat) {
        self.chat = chat
        self.assistant = Message(role: .assistant, provider: chat.config.provider, model: chat.config.model, isReplying: true)
        chat.addMessage(assistant)
    }

    @MainActor
    func handleRequest() async throws {
        chat.config.provider.host = chat.config.provider.host.trimmingCharacters(in: .whitespacesAndNewlines)
        if chat.config.stream {
            try await handleStream()
        } else {
            try await handleNonStream()
        }
    }
    
    @MainActor
    private func handleStream() async throws {
        var streamText = ""
        var lastUIUpdateTime = Date()
        var pendingToolCalls: [ChatToolCall] = []
        var inputTokens = 0
        var outputTokens = 0
        
        let service = chat.config.provider.type.getService()

        // must do droplast since last is the empty assistant message
        for try await response in service.streamResponse(from: chat.adjustedMessages.dropLast(), config: chat.config) {
            switch response {
            case .content(let content):
                streamText += content
                
                let currentTime = Date()
                if currentTime.timeIntervalSince(lastUIUpdateTime) >= Float.UIIpdateInterval {
                    assistant.content = streamText
                    lastUIUpdateTime = currentTime
                    chat.scrollBottom()
                }
            case .toolCalls(let calls):
                pendingToolCalls.append(contentsOf: calls)
            case .inputTokens(let tokens):
                inputTokens = tokens
            case .outputTokens(let tokens):
                outputTokens = tokens
            }
        }

        if !pendingToolCalls.isEmpty {
            try await handleToolCalls(pendingToolCalls)
        }
        
        finaliseStream(streamText: streamText, pendingToolCalls: pendingToolCalls, totalTokens: inputTokens + outputTokens)
    }
    
    private func finaliseStream(streamText: String = "", pendingToolCalls: [ChatToolCall], totalTokens: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Float.UIIpdateInterval) {
            chat.totalTokens = totalTokens
            assistant.toolCalls = pendingToolCalls
            assistant.content = streamText
            assistant.isReplying = false
            chat.scrollBottom()
            AppConfig.shared.hasUserScrolled = false
            try? assistant.modelContext?.save()
        }
    }

    @MainActor
    private func handleNonStream() async throws {
        let service = chat.config.provider.type.getService()
        let response = try await service.nonStreamingResponse(from: chat.adjustedMessages, config: chat.config)
        
        if let content = response.content {
            assistant.content = content
        }
        
        if let calls = response.toolCalls {
            try await handleToolCalls(calls)
        }
        
        chat.totalTokens = response.inputTokens + response.outputTokens
        assistant.isReplying = false
        chat.scrollBottom()
        AppConfig.shared.hasUserScrolled = false
        try? assistant.modelContext?.save()
    }

    @MainActor
    private func handleToolCalls(_ toolCalls: [ChatToolCall]) async throws {
        // DO NOT call this when assitant.toolCalls is already populated. this func does it for you
        assistant.isReplying = false
        assistant.toolCalls = toolCalls
        chat.scrollBottom()

        var toolDatas: [TypedData] = []
        
        for call in assistant.toolCalls {
            let toolResponse = ToolResponse(toolCallId: call.toolCallId, tool: call.tool)
            let tool = Message(toolResponse: toolResponse)
            chat.addMessage(tool) // TODO: use single response message insetad of multiple tool messages
            
            let toolData = try await call.tool.process(arguments: call.arguments)
            toolDatas.append(contentsOf: toolData.data)
            tool.toolResponse?.processedContent = toolData.string
            tool.toolResponse?.processedData = toolData.data // possibly never used
            tool.isReplying = false
            
            chat.scrollBottom()
        }
        
        if toolDatas.isEmpty {
            let streamer = StreamHandler(chat: chat)
            try await streamer.handleRequest()
        } else {
            let newAssistant = Message(role: .assistant, provider: chat.config.provider, model: chat.config.provider.imageModel)
            newAssistant.content = "Generations:"
            newAssistant.dataFiles = toolDatas
            newAssistant.isReplying = false
            chat.addMessage(newAssistant)
        }
    }
}
