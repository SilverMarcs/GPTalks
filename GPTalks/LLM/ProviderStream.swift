//
//  ProviderProtocol.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import OpenAI

class StreamManager {
    static func streamResponse(from conversationGroups: [ConversationGroup], config: SessionConfig) -> AsyncThrowingStream<String, Error> {
        switch config.provider.type {
        case .openai:
            let service = OpenAI(configuration: OpenAI.Configuration(token: config.provider.apiKey, host: config.provider.host))
            var messages = conversationGroups.map { $0.activeConversation.toQuery() }
            let query = ChatQuery(messages: messages, model: config.model.code, maxTokens: 4000, temperature: config.temperature)
            
            let systemPrompt = Conversation(role: .system, content: "System prompt")
            messages.insert(systemPrompt.toQuery(), at: 0)
            
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
        case .claude:
            // Return Claude stream
            return AsyncThrowingStream { _ in }
        case .google:
            // Return Google stream
            return AsyncThrowingStream { _ in }
        }
    }
}
