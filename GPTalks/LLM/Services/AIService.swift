//
//  AIService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import SwiftUI

protocol AIService {
    static func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<String, Error>
    static func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> String
    static func testModel(provider: Provider, model: AIModel) async -> Bool
}

//struct AIServiceFactory {
//    static func createService(for providerType: ProviderType) -> AIService.Type {
//        switch providerType {
//        case .openai, .local:
//            return OpenAIService.self
//        case .anthropic:
//            return ClaudeService.self
//        case .google:
//            return GoogleService.self
//        }
//    }
//}
