//
//  StreamHandler.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import Foundation
import SwiftUI

struct StreamHandler {
    private let conversations: [Thread]
    private let session: Chat
    private let assistant: Thread
    
    static let uiUpdateInterval: TimeInterval = Float.UIIpdateInterval

    init(conversations: [Thread], session: Chat, assistant: Thread) {
        self.conversations = conversations
        self.session = session
        self.assistant = assistant
    }

    @MainActor
    func handleRequest() async throws {
        if session.config.stream {
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
        
        let serviceType = session.config.provider.type.getService()

        assistant.isReplying = true

        for try await response in serviceType.streamResponse(from: conversations, config: session.config) {
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
        let serviceType = session.config.provider.type.getService()
        let response = try await serviceType.nonStreamingResponse(from: conversations, config: session.config)
        
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

    @MainActor
    private func finalizeStream(streamText: String, toolCalls: [ChatToolCall]) {
        assistant.toolCalls = toolCalls
        if !streamText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.uiUpdateInterval) {
                self.assistant.content = streamText
                self.assistant.isReplying = false
            }
        }
        
//        if !session.hasUserScrolled {
            session.scrollBottom()
            session.hasUserScrolled = false
//        }
        
        try? assistant.modelContext?.save()
    }

    @MainActor
    private func handleToolCalls(_ toolCalls: [ChatToolCall]) async throws {
        assistant.toolCalls = toolCalls
        session.scrollBottom()
        
        assistant.isReplying = false

        var toolDatas: [Data] = []
        
        if let session = assistant.group?.session {
            for toolCall in assistant.toolCalls {
                let toolResponse = ToolResponse(toolCallId: toolCall.toolCallId, tool: toolCall.tool, processedContent: "", processedData: [])
                let tool = Thread(role: .tool, provider: session.config.provider, model: session.config.model, toolResponse: toolResponse, isReplying: true)
                session.addThreadGroup(conversation: tool)
                
                let toolData = try await toolCall.tool.process(arguments: toolCall.arguments)
                toolDatas.append(contentsOf: toolData.data)
                tool.toolResponse?.processedContent = toolData.string
                tool.toolResponse?.processedData = toolData.data    
                tool.isReplying = false
                
                session.scrollBottom()
            }
            
            let newAssistant = Thread(role: .assistant, provider: session.config.provider, model: session.config.model, isReplying: true)
            session.addThreadGroup(conversation: newAssistant)
                          
            if toolDatas.isEmpty {
                session.streamer = StreamHandler(conversations: session.groups.map { $0.activeThread }.dropLast(), session: session, assistant: newAssistant)
                if let streamer = session.streamer {
                    if session.config.stream {
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
}
