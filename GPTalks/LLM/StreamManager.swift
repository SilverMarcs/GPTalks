//
//  StreamManager.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import Foundation
import GoogleGenerativeAI
import SwiftAnthropic
import OpenAI


struct StreamManager {
    static func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<String, Error> {
        let serviceType = AIServiceFactory.createService(for: config.provider.type)
        return serviceType.streamResponse(from: conversations, config: config)
    }

    static func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> String {
        let serviceType = AIServiceFactory.createService(for: config.provider.type)
        return try await serviceType.nonStreamingResponse(from: conversations, config: config)
    }
}
