//
//  StreamHandler.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import Foundation

class StreamHandler {
    private let config: SessionConfig
    private let assistant: Conversation
    private let uiUpdateInterval: TimeInterval
    
    init(config: SessionConfig, assistant: Conversation, uiUpdateInterval: TimeInterval = 0.1) {
        self.config = config
        self.assistant = assistant
        self.uiUpdateInterval = uiUpdateInterval
    }
    
    @MainActor
    func handleStream(from conversations: [Conversation]) async throws {
        var streamText = ""
        var lastUIUpdateTime = Date()
        
        let streamManager = StreamManager(config: config)
        let stream = streamManager.streamResponse(from: conversations)
        
        assistant.isReplying = true
        
        for try await content in stream {
            streamText += content
            let currentTime = Date()
            if currentTime.timeIntervalSince(lastUIUpdateTime) >= uiUpdateInterval {
                assistant.content = streamText
                lastUIUpdateTime = currentTime
            }
        }
        
        finalizeStream(streamText: streamText)
    }
    
    @MainActor
    func returnStreamText(from conversations: [Conversation]) async throws -> String {
        var streamText = ""
        
        let streamManager = StreamManager(config: config)
        let stream = streamManager.streamResponse(from: conversations)
        
        for try await content in stream {
            streamText += content
        }
        
        return streamText
    }
    
    @MainActor
    private func finalizeStream(streamText: String) {
        if !streamText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + uiUpdateInterval) {
                self.assistant.content = streamText
                self.assistant.isReplying = false
            }
        }
        if let context = self.assistant.modelContext {
            try? context.save()
        }
    }
    
    @MainActor
    func handleNonStreamingResponse(from conversations: [Conversation]) async throws -> String {
        let streamManager = StreamManager(config: config)
        let response = try await streamManager.nonStreamingResponse(from: conversations)
        
        return response
    }
}
