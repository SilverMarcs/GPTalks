//
//  StreamHandler.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
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
            let response = try await handleNonStreamingResponse(from: conversations, config: config, assistant: assistant)
            assistant.content = response
        }
    }

    @MainActor
    private static func handleStream(from conversations: [Conversation], config: SessionConfig, assistant: Conversation) async throws {
        var streamText = ""
        var lastUIUpdateTime = Date()

//        let stream = StreamManager.streamResponse(from: conversations, config: config)
        
        let serviceType = AIServiceFactory.createService(for: config.provider.type)

        assistant.isReplying = true

        for try await content in serviceType.streamResponse(from: conversations, config: config) {
            streamText += content
            let currentTime = Date()
            if currentTime.timeIntervalSince(lastUIUpdateTime) >= uiUpdateInterval {
                assistant.content = streamText
                lastUIUpdateTime = currentTime
            }
        }

        finalizeStream(streamText: streamText, assistant: assistant)
    }

    @MainActor
    private static func handleNonStreamingResponse(from conversations: [Conversation], config: SessionConfig, assistant: Conversation) async throws -> String {
        assistant.isReplying = true
//        let response = try await StreamManager.nonStreamingResponse(from: conversations, config: config)
        let serviceType = AIServiceFactory.createService(for: config.provider.type)
        let response = try await serviceType.nonStreamingResponse(from: conversations, config: config)
        
        assistant.isReplying = false

        return response
    }
    
    static func handleTitleGeneration(from conversations: [Conversation], config: SessionConfig) async throws -> String {
        let serviceType = AIServiceFactory.createService(for: config.provider.type)
        return try await serviceType.nonStreamingResponse(from: conversations, config: config)
    }

    @MainActor
    private static func finalizeStream(streamText: String, assistant: Conversation) {
        if !streamText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + uiUpdateInterval) {
                assistant.content = streamText
                assistant.isReplying = false
            }
        }

        try? assistant.modelContext?.save()
    }
}
