//
//  OpenAIService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import Foundation
import SwiftUI
import OpenAI

class OpenAIService: AIService {
    func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<String, Error> {
        let query = createQuery(from: conversations, config: config, stream: true)
        return streamOpenAIResponse(query: query, config: config)
    }
    
    func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> String {
        let query = createQuery(from: conversations, config: config, stream: false)
        return try await nonStreamingOpenAIResponse(query: query, config: config)
    }
    
    private func createQuery(from conversations: [Conversation], config: SessionConfig, stream: Bool) -> ChatQuery {
        var messages = conversations.map { $0.toOpenAI() }
        let systemPrompt = Conversation(role: .system, content: config.systemPrompt)
        messages.insert(systemPrompt.toOpenAI(), at: 0)
        
        return ChatQuery(
            messages: messages,
            model: config.model.code,
            frequencyPenalty: config.frequencyPenalty,
            maxTokens: config.maxTokens,
            presencePenalty: config.presencePenalty,
            temperature: config.temperature,
            topP: config.topP,
            stream: stream
        )
    }
    
    private func streamOpenAIResponse(query: ChatQuery, config: SessionConfig) -> AsyncThrowingStream<String, Error> {
        let service = OpenAI(configuration: OpenAI.Configuration(token: config.provider.apiKey, host: config.provider.host, scheme: config.provider.type.scheme))
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await result in service.chatsStream(query: query) {
                        let chatStreamResult = result as ChatStreamResult
                        let content = chatStreamResult.choices.first?.delta.content ?? ""
                        continuation.yield(content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func nonStreamingOpenAIResponse(query: ChatQuery, config: SessionConfig) async throws -> String {
        let service = OpenAI(configuration: OpenAI.Configuration(token: config.provider.apiKey, host: config.provider.host, scheme: config.provider.type.scheme))
        
        let result = try await service.chats(query: query)
        return result.choices.first?.message.content?.string ?? ""
    }
    
    func testModel(provider: Provider, model: AIModel) async -> Bool {
        let messages = [Conversation(role: .user, content: String.testPrompt).toOpenAI()]
        let query = ChatQuery(messages: messages, model: model.code)
        let service = OpenAI(configuration: OpenAI.Configuration(token: provider.apiKey, host: provider.host, scheme: provider.type.scheme))
        
        do {
            let result = try await service.chats(query: query)
            return result.choices.first?.message.content?.string != nil
        } catch {
            return false
        }
    }
}
