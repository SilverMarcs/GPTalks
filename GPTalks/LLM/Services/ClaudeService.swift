//
//  ClaudeService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import Foundation
import SwiftUI
import SwiftAnthropic

class ClaudeService: AIService {
    func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<String, Error> {
        let parameters = createParameters(from: conversations, config: config, stream: true)
        return streamClaudeResponse(parameters: parameters, config: config)
    }
    
    func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> String {
        let parameters = createParameters(from: conversations, config: config, stream: false)
        return try await nonStreamingClaudeResponse(parameters: parameters, config: config)
    }
    
    private func createParameters(from conversations: [Conversation], config: SessionConfig, stream: Bool) -> MessageParameter {
        let messages = conversations.map { $0.toClaude() }
        let systemPrompt = MessageParameter.System.text(config.systemPrompt)
        
        return MessageParameter(
            model: .other(config.model.code),
            messages: messages,
            maxTokens: config.maxTokens ?? 4096,
            system: systemPrompt,
            stream: stream,
            temperature: config.temperature,
            topP: config.topP
        )
    }
    
    private func streamClaudeResponse(parameters: MessageParameter, config: SessionConfig) -> AsyncThrowingStream<String, Error> {
        let betaHeaders = ["prompt-caching-2024-07-31", "max-tokens-3-5-sonnet-2024-07-15"]
        let service = AnthropicServiceFactory.service(
            apiKey: config.provider.apiKey,
            basePath: config.provider.type.scheme + "://" + config.provider.host, betaHeaders: betaHeaders)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let response = try await service.streamMessage(parameters)
                    for try await result in response {
                        if let content = result.delta?.text {
                            continuation.yield(content)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func nonStreamingClaudeResponse(parameters: MessageParameter, config: SessionConfig) async throws -> String {
        let betaHeaders = ["prompt-caching-2024-07-31", "max-tokens-3-5-sonnet-2024-07-15"]
        let service = AnthropicServiceFactory.service(
            apiKey: config.provider.apiKey,
            basePath: config.provider.type.scheme + "://" + config.provider.host, betaHeaders: betaHeaders)
        
        let message = try await service.createMessage(parameters)
        // Extract the text content from the message
        let content = message.content.compactMap { content -> String? in
            switch content {
            case .text(let text):
                return text
            case .toolUse:
                return nil // TODO:
            }
        }.joined()
        
        return content
    }
    
    func testModel(provider: Provider, model: AIModel) async -> Bool {
        let betaHeaders = ["prompt-caching-2024-07-31", "max-tokens-3-5-sonnet-2024-07-15"]  
        let service = AnthropicServiceFactory.service(
            apiKey: provider.apiKey,
            basePath: provider.type.scheme + "://" + provider.host, betaHeaders: betaHeaders)
        
        let messageParameter = MessageParameter(
            model: .other(model.code),
            messages: [MessageParameter.Message(role: .user, content: .text(String.testPrompt))],
            maxTokens: 16,
            stream: false
        )
        
        do {
            let response = try await service.createMessage(messageParameter)
            return response.content.count > 0
        } catch {
            return false
        }
    }
}
