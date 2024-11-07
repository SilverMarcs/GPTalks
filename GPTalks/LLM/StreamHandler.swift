//
//  StreamHandler.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import Foundation
import SwiftUI

struct StreamHandler {
    private let session: Chat
    private var assistant: Thread // TODO: maybe need ot fidn diff way of getting setting assistant
    
    static let uiUpdateInterval: TimeInterval = Float.UIIpdateInterval

    init(session: Chat) {
        self.session = session
        self.assistant = Thread(role: .assistant, provider: session.config.provider, model: session.config.model, isReplying: true)
        session.addThread(assistant)
    }

    @MainActor
    func handleRequest() async throws {
        if session.config.stream {
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
        
        let service = session.config.provider.type.getService()

        for try await response in service.streamResponse(from: session.threads, config: session.config) {
            switch response {
            case .content(let content):
                streamText += content
                
                let currentTime = Date()
                if currentTime.timeIntervalSince(lastUIUpdateTime) >= Self.uiUpdateInterval {
                    assistant.content = streamText
                    lastUIUpdateTime = currentTime
                    session.scrollBottom()
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
    
    @MainActor
    private func finaliseStream(streamText: String = "", pendingToolCalls: [ChatToolCall], totalTokens: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.uiUpdateInterval) {
            session.totalTokens = totalTokens
            assistant.toolCalls = pendingToolCalls
            assistant.content = streamText
            assistant.isReplying = false
            session.scrollBottom()
            session.hasUserScrolled = false
            try? assistant.modelContext?.save()
        }
    }

    @MainActor
    private func handleNonStream() async throws {
        let service = session.config.provider.type.getService()
        let response = try await service.nonStreamingResponse(from: session.threads, config: session.config)
        
        if let content = response.content {
            assistant.content = content
        }
        
        if let calls = response.toolCalls {
            try await handleToolCalls(calls)
        }
        
        session.totalTokens = response.inputTokens + response.outputTokens
        assistant.isReplying = false
        session.scrollBottom()
        session.hasUserScrolled = false
        try? assistant.modelContext?.save()
    }

    @MainActor
    private func handleToolCalls(_ toolCalls: [ChatToolCall]) async throws {
        // DO NOT call this when assitant.toolCalls is already populated. this func does it for you
        assistant.isReplying = false
        assistant.toolCalls = toolCalls
        session.scrollBottom()

        var toolDatas: [TypedData] = []
        
        for call in assistant.toolCalls {
            let toolResponse = ToolResponse(toolCallId: call.toolCallId, tool: call.tool)
            let tool = Thread(toolResponse: toolResponse)
            session.addThread(tool) // TODO: use single response thread insetad of multiple tool threads
            
            let toolData = try await call.tool.process(arguments: call.arguments)
            toolDatas.append(contentsOf: toolData.data)
            tool.toolResponse?.processedContent = toolData.string
            tool.toolResponse?.processedData = toolData.data // possibly never used
            tool.isReplying = false
            
            session.scrollBottom()
        }
        
        if toolDatas.isEmpty {
            let streamer = StreamHandler(session: session)
            try await streamer.handleRequest()
        } else {
            let newAssistant = Thread(role: .assistant, provider: session.config.provider, model: session.config.provider.toolImageModel)
            newAssistant.content = "Generations:"
            newAssistant.dataFiles = toolDatas
            newAssistant.isReplying = false
            session.addThread(newAssistant)
        }
    }
}
