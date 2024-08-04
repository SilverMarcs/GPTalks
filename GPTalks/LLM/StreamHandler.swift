//
//  StreamHandler.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import Foundation
import SwiftUI

class StreamHandler {
    private let config: SessionConfig
    private let assistant: Conversation
    private let uiUpdateInterval: TimeInterval = Float.UIIpdateInterval
    
    init(config: SessionConfig, assistant: Conversation) {
        self.config = config
        self.assistant = assistant
    }
    
    @MainActor
    func handleRequest(from conversations: [Conversation]) async throws {
        if config.stream {
            try await handleStream(from: conversations)
        } else {
            let response = try await handleNonStreamingResponse(from: conversations)
            assistant.content = response
        }
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
    func handleNonStreamingResponse(from conversations: [Conversation]) async throws -> String {
        let streamManager = StreamManager(config: config)
        
        assistant.isReplying = true
        let response = try await streamManager.nonStreamingResponse(from: conversations)
        assistant.isReplying = false
        
        return response
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
}
