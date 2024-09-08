//
//  OpenAIService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import Foundation
import SwiftUI
import OpenAI

struct OpenAIService: AIService {
    typealias ConvertedType = ChatQuery.ChatCompletionMessageParam
    
    static func convert(conversation: Conversation) -> ConvertedType {
        if conversation.dataFiles.isEmpty {
            return ChatQuery.ChatCompletionMessageParam(
                role: conversation.role.toOpenAIRole(),
                content: conversation.content
            )!
        } else {
            var visionContent: [ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content.VisionContent] = []
            
            for dataFile in conversation.dataFiles {
                if dataFile.fileType.conforms(to: .image) {
                    visionContent.append(.init(chatCompletionContentPartImageParam: .init(imageUrl: .init(url: dataFile.data, detail: .auto))))
                } else if dataFile.fileType.conforms(to: .pdf) {
                    if let url = FileHelper.createTemporaryURL(for: dataFile) {
                        let contents = readPDF(from: url)
                        visionContent.append(.init(chatCompletionContentPartTextParam: .init(text: "PDF File contents: \n\(contents)\n Respond to the user based on their query.")))
                    }
                } else if dataFile.fileType.conforms(to: .text) {
                    if let textContent = String(data: dataFile.data, encoding: .utf8) {
                        visionContent.append(.init(chatCompletionContentPartTextParam: .init(text: "Text File contents: \n\(textContent)\n Respond to the user based on their query.")))
                    }
                }
            }
            
            visionContent.append(.init(chatCompletionContentPartTextParam: .init(text: conversation.content)))

            return ChatQuery.ChatCompletionMessageParam(
                role: conversation.role.toOpenAIRole(),
                content: visionContent
            )!
        }
    }
    
    static func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<String, Error> {
        let query = createQuery(from: conversations, config: config, stream: config.stream)
        return streamOpenAIResponse(query: query, config: config)
    }
    
    static func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> String {
        let query = createQuery(from: conversations, config: config, stream: config.stream)
        return try await nonStreamingOpenAIResponse(query: query, config: config)
    }
    
    static func createQuery(from conversations: [Conversation], config: SessionConfig, stream: Bool) -> ChatQuery {
        var messages = conversations.map { convert(conversation: $0) }
        if !config.systemPrompt.isEmpty {
            let systemPrompt = Conversation(role: .system, content: config.systemPrompt)
            messages.insert(systemPrompt.toOpenAI(), at: 0)
        }
        
        return ChatQuery(
            messages: messages,
            model: config.model.code,
            frequencyPenalty: config.frequencyPenalty,
            maxTokens: config.maxTokens,
            presencePenalty: config.presencePenalty,
            temperature: config.temperature,
//            tools: [],
            topP: config.topP,
            stream: stream
        )
    }
    
    static func streamOpenAIResponse(query: ChatQuery, config: SessionConfig) -> AsyncThrowingStream<String, Error> {
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
    
    static func nonStreamingOpenAIResponse(query: ChatQuery, config: SessionConfig) async throws -> String {
        let service = OpenAI(configuration: OpenAI.Configuration(token: config.provider.apiKey, host: config.provider.host, scheme: config.provider.type.scheme))
        
        let result = try await service.chats(query: query)
        return result.choices.first?.message.content?.string ?? ""
    }
    
    static func testModel(provider: Provider, model: AIModel) async -> Bool {
        let messages = [convert(conversation: Conversation(role: .user, content: String.testPrompt))]
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
