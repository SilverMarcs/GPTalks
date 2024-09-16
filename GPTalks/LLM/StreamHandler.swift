//
//  StreamHandler.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import Foundation
import SwiftUI

struct StreamHandler {
    static let uiUpdateInterval: TimeInterval = Float.UIIpdateInterval

    @MainActor
    static func handleRequest(from conversations: [Conversation], config: SessionConfig, assistant: Conversation) async throws {
        if config.stream {
            try await handleStream(from: conversations, config: config, assistant: assistant)
        } else {
            try await handleNonStreamingResponse(from: conversations, config: config, assistant: assistant)
        }
    }

    @MainActor
    private static func handleStream(from conversations: [Conversation], config: SessionConfig, assistant: Conversation) async throws {
        var streamText = ""
        var lastUIUpdateTime = Date()
        var pendingToolCalls: [ToolCall] = []
        
        let serviceType = config.provider.type.getService()

        assistant.isReplying = true

        for try await response in serviceType.streamResponse(from: conversations, config: config) {
            switch response {
            case .content(let content):
                streamText += content
                let currentTime = Date()
                
                if currentTime.timeIntervalSince(lastUIUpdateTime) >= uiUpdateInterval {
                    assistant.content = streamText
                    lastUIUpdateTime = currentTime
                }
            case .toolCalls(let calls):
                pendingToolCalls.append(contentsOf: calls)
            }
        }

        // Handle all collected tool calls after the stream is complete
        if !pendingToolCalls.isEmpty {
            try await handleToolCalls(pendingToolCalls, config: config, assistant: assistant)
        }

        finalizeStream(streamText: streamText, toolCalls: pendingToolCalls, assistant: assistant)
    }

    @MainActor
    private static func handleNonStreamingResponse(from conversations: [Conversation], config: SessionConfig, assistant: Conversation) async throws {
        assistant.isReplying = true
        let serviceType = config.provider.type.getService()
        let response = try await serviceType.nonStreamingResponse(from: conversations, config: config)
        
        switch response {
        case .content(let content):
            assistant.content = content
        case .toolCalls(let calls):
            // Handle tool calls
            try await handleToolCalls(calls, config: config, assistant: assistant)
        }
        
        // If there were no tool calls, we can set isReplying to false here
        if assistant.toolCalls.isEmpty {
            assistant.isReplying = false
        }
        
        try? assistant.modelContext?.save()
    }


    
    static func handleTitleGeneration(from conversations: [Conversation], config: SessionConfig) async throws -> String {
        let serviceType = config.provider.type.getService()
        let response = try await serviceType.nonStreamingResponse(from: conversations, config: config)
        
        switch response {
        case .content(let content):
            return content
        case .toolCalls:
            throw NSError(domain: "UnexpectedResponse", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Expected content but got tool calls"])
        }
    }

    @MainActor
    private static func finalizeStream(streamText: String, toolCalls: [ToolCall], assistant: Conversation) {
        assistant.toolCalls = toolCalls
        if !streamText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + uiUpdateInterval) {
                assistant.content = streamText
                assistant.isReplying = false
            }
        }

        try? assistant.modelContext?.save()
    }


    @MainActor
    private static func handleToolCalls(_ toolCalls: [ToolCall], config: SessionConfig, assistant: Conversation) async throws {
        assistant.toolCalls = toolCalls
        if let proxy = assistant.group?.session?.proxy {
            scrollToBottom(proxy: proxy)
        }
        
        assistant.isReplying = false

        var toolDatas: [Data] = []
        
        if let session = assistant.group?.session {
            for toolCall in assistant.toolCalls {
                let toolResponse = ToolResponse(toolCallId: toolCall.toolCallId, tool: toolCall.tool, processedContent: "", processedData: [])
                let tool = Conversation(role: .tool, model: config.model, isReplying: true, toolResponse: toolResponse)
                session.addConversationGroup(conversation: tool)
                
                let toolData = await toolCall.tool.process(arguments: toolCall.arguments, modelContext: session.modelContext)
                toolDatas.append(contentsOf: toolData.data)
                tool.toolResponse?.processedContent = toolData.string
                tool.toolResponse?.processedData = toolData.data
                
                tool.isReplying = false
                if let proxy = tool.group?.session?.proxy {
                    scrollToBottom(proxy: proxy)
                }
            }
            
            let assistant = Conversation(role: .assistant, model: config.model, isReplying: true)
            session.addConversationGroup(conversation: assistant)
            if let proxy = assistant.group?.session?.proxy {
                scrollToBottom(proxy: proxy)
            }
                          
            if toolDatas.isEmpty {
                if config.stream {
                    try await handleStream(from: session.adjustedGroups.map { $0.activeConversation }.dropLast(), config: config, assistant: assistant)
                } else {
                    try await handleNonStreamingResponse(from: session.adjustedGroups.map { $0.activeConversation }.dropLast(), config: config, assistant: assistant)
                }
            } else {
                let typedDataFiles = toolDatas.map { data in
                    TypedData(
                        data: data,
                        fileType: .image,
                        fileName: "image",
                        fileSize: "\(data.count) bytes",
                        fileExtension: "png"
                    )
                }
                assistant.dataFiles = typedDataFiles
                assistant.isReplying = false
            }
        }
    }
}
