//
//  AIService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import SwiftUI

protocol AIService {
    func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<String, Error>
    func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> String
    func testModel(provider: Provider, model: AIModel) async -> Bool
}

protocol AIServiceFactory {
    func createService(for providerType: ProviderType) -> AIService
}

class DefaultAIServiceFactory: AIServiceFactory {
    func createService(for providerType: ProviderType) -> AIService {
        switch providerType {
        case .openai, .local:
            return OpenAIService()
        case .anthropic:
            return ClaudeService()
        case .google:
            return GoogleService()
        }
    }
}
