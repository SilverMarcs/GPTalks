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
            }
        }

        if !pendingToolCalls.isEmpty {
            try await handleToolCalls(pendingToolCalls)
        }

        finalizeStream(streamText: streamText, toolCalls: pendingToolCalls)
    }

    @MainActor
    private func handleNonStream() async throws {
        let service = session.config.provider.type.getService()
        let response = try await service.nonStreamingResponse(from: session.threads, config: session.config)
        
        switch response {
        case .content(let content):
            assistant.content = content
            assistant.isReplying = false
        case .toolCalls(let calls):
            try await handleToolCalls(calls)
        }
    }

    @MainActor
    private func finalizeStream(streamText: String, toolCalls: [ChatToolCall]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.uiUpdateInterval) {
            assistant.toolCalls = toolCalls
            assistant.content = streamText
            assistant.isReplying = false
            session.scrollBottom()
            session.hasUserScrolled = false
            try? assistant.modelContext?.save()
        }
    }

    @MainActor
    private func handleToolCalls(_ toolCalls: [ChatToolCall]) async throws {
        // DO NOT call this when assitant.toolCalls is already populated. this func does it for you
        assistant.toolCalls = toolCalls
        session.scrollBottom()
        
        assistant.isReplying = false

        var toolDatas: [Data] = []
        
        for call in assistant.toolCalls {
            let toolResponse = ToolResponse(toolCallId: call.toolCallId, tool: call.tool)
            let tool = Thread(toolResponse: toolResponse)
            session.addThread(tool) // TODO: use single response thread insetad of multiple tool threads
            
            let toolData = try await call.tool.process(arguments: call.arguments)
            toolDatas.append(contentsOf: toolData.data)
            tool.toolResponse?.processedContent = toolData.string
            tool.toolResponse?.processedData = toolData.data
            tool.isReplying = false
            
            session.scrollBottom()
        }
        
        // TODO: already doing this in init. why duplicate? maybe do this in handleRequest()
        let streamer = StreamHandler(session: session)
                      
        if toolDatas.isEmpty {
            try await streamer.handleRequest()
        } else {
            // when assistant returns a data file, we handle differently
            let typedDataFiles = toolDatas.map { data in
                TypedData(
                    data: data,
                    fileType: .image,
                    fileName: "image"
                )
            }
            let newAssistant = Thread(role: .assistant, provider: session.config.provider, model: session.config.model, isReplying: true)
            newAssistant.dataFiles = typedDataFiles
            newAssistant.isReplying = false
        }
    }
}
