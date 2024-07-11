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
    
    init(config: SessionConfig) {
        self.config = config
    }
    
    func streamResponse(from conversations: [Conversation])
    -> AsyncThrowingStream<String, Error>
    {
        switch config.provider.type {
        case .openai:
            return streamOpenAIResponse(from: conversations)
        case .claude:
            return streamClaudeResponse(from: conversations)
        case .google:
            return streamGoogleResponse(from: conversations)
        }
    }
    
    func nonStreamingResponse(from conversations: [Conversation]) async throws -> String {
        switch config.provider.type {
        case .openai:
            return try await nonStreamingOpenAIResponse(from: conversations)
        case .claude:
            return try await nonStreamingClaudeResponse(from: conversations)
        case .google:
            return try await nonStreamingGoogleResponse(from: conversations)
        }
    }
    
    private func nonStreamingOpenAIResponse(from conversations: [Conversation]) async throws -> String {
        let service = OpenAI(configuration: OpenAI.Configuration(token: config.provider.apiKey, host: config.provider.host))
        
        var messages = conversations.map { $0.toOpenAI() }
        let systemPrompt = Conversation(role: .system, content: config.systemPrompt)
        messages.insert(systemPrompt.toOpenAI(), at: 0)
        
        let query = ChatQuery(
            messages: messages,
            model: config.model.code,
            maxTokens: 4096,
            temperature: config.temperature,
            stream: false
        )
        
        let result = try await service.chats(query: query)
        return result.choices.first?.message.content?.string ?? ""
    }
    
    private func nonStreamingClaudeResponse(from conversations: [Conversation]) async throws -> String {
        // Default implementation for Claude
        return "Non-streaming response not implemented for Claude"
    }
    
    private func nonStreamingGoogleResponse(from conversations: [Conversation]) async throws -> String {
        // Default implementation for Google
        return "Non-streaming response not implemented for Google"
    }
    
    private func streamOpenAIResponse(from conversations: [Conversation]) -> AsyncThrowingStream<String, Error> {
        let service = OpenAI(
            configuration: OpenAI.Configuration(
                token: config.provider.apiKey, host: config.provider.host))
        
        var messages = conversations.map {
            $0.toOpenAI()
        }
        
        let systemPrompt = Conversation(
            role: .system, content: config.systemPrompt)
        messages.insert(systemPrompt.toOpenAI(), at: 0)
        
        let query = ChatQuery(
            messages: messages,
            model: config.model.code,
            maxTokens: 4096,
            temperature: config.temperature,
            stream: true)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await result in service.chatsStream(query: query) {
                        let chatStreamResult = result as ChatStreamResult
                        let content =
                        chatStreamResult.choices.first?.delta.content ?? ""
                        continuation.yield(content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func streamClaudeResponse(from conversations: [Conversation]) -> AsyncThrowingStream<String, Error> {
        let service = AnthropicServiceFactory.service(
            apiKey: config.provider.apiKey,
            basePath: "https://" + config.provider.host)
        
        let messages = conversations.map {
            $0.toClaude()
        }
        
        let parameters = MessageParameter(
            model: .other(config.model.code),
            messages: messages,
            maxTokens: 4096,
            system: config.systemPrompt,
            stream: true,
            temperature: config.temperature)
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
    
    private func streamGoogleResponse(from conversations: [Conversation]) -> AsyncThrowingStream<String, Error> {
        let systemPrompt = ModelContent(
            role: "system", parts: [.text(config.systemPrompt)])
        
        let genConfig = GenerationConfig(
            temperature: Float(config.temperature),
            maxOutputTokens: 8192)
        
        let model = GenerativeModel(
            name: config.model.code,
            apiKey: config.provider.apiKey,
            generationConfig: genConfig,
            systemInstruction: systemPrompt)
        
        let messages = conversations.map {
            $0.toGoogle()
        }
        let _ = model.startChat(history: messages)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let responseStream = model.generateContentStream(
                        messages)
                    
                    for try await response in responseStream {
                        // Extract the content from the response
                        if let content = response.text {
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
}
