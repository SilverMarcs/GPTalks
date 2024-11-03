//
//  StreamHandler.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import Foundation
import SwiftUI

struct StreamHandler {
    private let conversations: [Conversation]
    private let config: SessionConfig
    private let assistant: Conversation
    
    static let uiUpdateInterval: TimeInterval = Float.UIIpdateInterval

    init(conversations: [Conversation], config: SessionConfig, assistant: Conversation) {
        self.conversations = conversations
        self.config = config
        self.assistant = assistant
    }

    @MainActor
    func handleRequest() async throws {
        if config.stream {
            try await handleStream()
        } else {
            try await handleNonStreamingResponse()
        }
    }
    
    @MainActor
    private func handleStream() async throws {
        var streamText = ""
        var lastUIUpdateTime = Date()
        var pendingToolCalls: [ChatToolCall] = []
        
        let serviceType = config.provider.type.getService()

        assistant.isReplying = true

        for try await response in serviceType.streamResponse(from: conversations, config: config) {
            switch response {
            case .content(let content):
                streamText += content
                let currentTime = Date()
                
                if currentTime.timeIntervalSince(lastUIUpdateTime) >= Self.uiUpdateInterval {
                    assistant.content = streamText
                    lastUIUpdateTime = currentTime
                }
            case .toolCalls(let calls):
                pendingToolCalls.append(contentsOf: calls)
            }
        }

        if !pendingToolCalls.isEmpty {
            try await handleToolCalls(pendingToolCalls)
        }

        finalizeStream(streamText: streamText, toolCalls: pendingToolCalls)
    }

    @MainActor
    private func handleNonStreamingResponse() async throws {
        assistant.isReplying = true
        let serviceType = config.provider.type.getService()
        let response = try await serviceType.nonStreamingResponse(from: conversations, config: config)
        
        switch response {
        case .content(let content):
            assistant.content = content
        case .toolCalls(let calls):
            try await handleToolCalls(calls)
        }
        
        if assistant.toolCalls.isEmpty {
            assistant.isReplying = false
        }
    }
    
    func handleTitleGeneration() async throws -> String {
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
    private func finalizeStream(streamText: String, toolCalls: [ChatToolCall]) {
        assistant.toolCalls = toolCalls
        if !streamText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.uiUpdateInterval) {
                self.assistant.content = streamText
                self.assistant.isReplying = false
            }
        }
        
        try? assistant.modelContext?.save()
    }

    @MainActor
    private func handleToolCalls(_ toolCalls: [ChatToolCall]) async throws {
        assistant.toolCalls = toolCalls
        if let proxy = assistant.group?.session?.proxy {
            scrollToBottom(proxy: proxy)
        }
        
        assistant.isReplying = false

        var toolDatas: [Data] = []
        
        if let session = assistant.group?.session {
            for toolCall in assistant.toolCalls {
                let toolResponse = ToolResponse(toolCallId: toolCall.toolCallId, tool: toolCall.tool, processedContent: "", processedData: [])
                let tool = Conversation(role: .tool, provider: config.provider, model: config.model, toolResponse: toolResponse, isReplying: true)
                session.addConversationGroup(conversation: tool)
                
                let toolData = try await toolCall.tool.process(arguments: toolCall.arguments)
                toolDatas.append(contentsOf: toolData.data)
                tool.toolResponse?.processedContent = toolData.string
                tool.toolResponse?.processedData = toolData.data    
                tool.isReplying = false
                
                if let proxy = tool.group?.session?.proxy {
                    scrollToBottom(proxy: proxy)
                }
            }
            
            let newAssistant = Conversation(role: .assistant, provider: config.provider, model: config.model, isReplying: true)
            session.addConversationGroup(conversation: newAssistant)
            if let proxy = newAssistant.group?.session?.proxy {
                scrollToBottom(proxy: proxy)
            }
                          
            if toolDatas.isEmpty {
                session.streamer = StreamHandler(conversations: session.groups.map { $0.activeConversation }.dropLast(), config: config, assistant: newAssistant)
                if let streamer = session.streamer {
                    if config.stream {
                        try await streamer.handleStream()
                    } else {
                        try await streamer.handleNonStreamingResponse()
                    }
                }
            } else {
                let typedDataFiles = toolDatas.map { data in
                    TypedData(
                        data: data,
                        fileType: .image,
                        fileName: "image"
                    )
                }
                newAssistant.dataFiles = typedDataFiles
                newAssistant.isReplying = false
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo("Bottom")
        }
    }
}
