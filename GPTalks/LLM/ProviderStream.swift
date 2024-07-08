//
//  ProviderProtocol.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import OpenAI
import GoogleGenerativeAI

class StreamManager {
    static func streamResponse(from conversationGroups: [ConversationGroup], config: SessionConfig) -> AsyncThrowingStream<String, Error> {
        switch config.provider.type {
        case .openai:
            let service = OpenAI(configuration: OpenAI.Configuration(token: config.provider.apiKey, host: config.provider.host))
            var messages = conversationGroups.map { $0.activeConversation.toOpenAI() }
            let query = ChatQuery(messages: messages, 
                                  model: config.model.code,
                                  maxTokens: 4096,
                                  temperature: config.temperature)
            
            let systemPrompt = Conversation(role: .system, content: config.systemPrompt)
            messages.insert(systemPrompt.toOpenAI(), at: 0)
            
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
            return AsyncThrowingStream { _ in }
        case .google:
            let systemPrompt = ModelContent(role: "system", parts: [.text(config.systemPrompt)])
            let genConfig = GenerationConfig(temperature: Float(config.temperature),
                                            maxOutputTokens: 8192)
            
            let model = GenerativeModel(name: config.model.code, 
                                        apiKey: config.provider.apiKey,
                                        generationConfig: genConfig,
                                        systemInstruction: systemPrompt)
            
            let modelContents = conversationGroups.map { $0.activeConversation.toGoogle() }
            let _ = model.startChat(history: modelContents)
            
            return AsyncThrowingStream { continuation in
                Task {
                    do {
                        let responseStream = model.generateContentStream(modelContents)
                        
                        for try await response in responseStream {
                            // Extract the content from the response
                            if let content = response.text {
                                continuation.yield(content)
                            }
                        }
                        
                        // Signal the end of the stream
                        continuation.finish()
                    } catch {
                        // Handle any errors that occur
                        continuation.finish(throwing: error)
                    }
                }
            }
        }
    }
}
