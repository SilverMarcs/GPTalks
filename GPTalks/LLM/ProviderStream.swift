//
//  ProviderProtocol.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import GoogleGenerativeAI
import SwiftAnthropic
import OpenAI

class StreamManager {
    private let config: SessionConfig

    init(config: SessionConfig) {
        self.config = config
    }

    func streamResponse(from conversationGroups: [ConversationGroup])
        -> AsyncThrowingStream<String, Error>
    {
        switch config.provider.type {
        case .openai:
            return streamOpenAIResponse(from: conversationGroups)
        case .claude:
            return streamClaudeResponse(from: conversationGroups)
        case .google:
            return streamGoogleResponse(from: conversationGroups)
        }
    }

    private func streamOpenAIResponse(from conversationGroups: [ConversationGroup]) -> AsyncThrowingStream<String, Error> {
        let service = OpenAI(
            configuration: OpenAI.Configuration(
                token: config.provider.apiKey, host: config.provider.host))
        var messages = conversationGroups.map {
            $0.activeConversation.toOpenAI()
        }
        let query = ChatQuery(
            messages: messages,
            model: config.model.code,
            maxTokens: 4096,
            temperature: config.temperature,
            stream: true)

        let systemPrompt = Conversation(
            role: .system, content: config.systemPrompt)
        messages.insert(systemPrompt.toOpenAI(), at: 0)

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

    private func streamClaudeResponse(from conversationGroups: [ConversationGroup]) -> AsyncThrowingStream<String, Error> {
        let service = AnthropicServiceFactory.service(
            apiKey: config.provider.apiKey,
            basePath: "https://" + config.provider.host)
    
        let messages = conversationGroups.map {
            $0.activeConversation.toClaude()
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

    private func streamGoogleResponse(from conversationGroups: [ConversationGroup]) -> AsyncThrowingStream<String, Error> {
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

        let modelContents = conversationGroups.map {
            $0.activeConversation.toGoogle()
        }
        let _ = model.startChat(history: modelContents)

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let responseStream = model.generateContentStream(
                        modelContents)

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
