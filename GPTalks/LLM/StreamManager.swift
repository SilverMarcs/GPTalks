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


class StreamManager {
    private let config: SessionConfig
    private let serviceFactory: AIServiceFactory
    
    init(config: SessionConfig, serviceFactory: AIServiceFactory = DefaultAIServiceFactory()) {
        self.config = config
        self.serviceFactory = serviceFactory
    }
    
    func streamResponse(from conversations: [Conversation]) -> AsyncThrowingStream<String, Error> {
        let service = serviceFactory.createService(for: config.provider.type)
        return service.streamResponse(from: conversations, config: config)
    }
    
    func nonStreamingResponse(from conversations: [Conversation]) async throws -> String {
        let service = serviceFactory.createService(for: config.provider.type)
        return try await service.nonStreamingResponse(from: conversations, config: config)
    }
}
