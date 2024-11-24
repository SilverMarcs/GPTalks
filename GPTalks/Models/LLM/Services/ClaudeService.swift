//
//  ClaudeService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import Foundation
import SwiftUI
import SwiftAnthropic

struct ClaudeService: AIService {
    typealias ConvertedType = MessageParameter.Message
    
    static func convert(conversation: Message) -> MessageParameter.Message {
        let contentItems = FileHelper.processDataFiles(conversation.dataFiles, messageId: conversation.id.uuidString, role: conversation.role)
        var contentObjects: [MessageParameter.Message.Content.ContentObject] = []
        for item in contentItems {
            switch item {
            case .text(let text):
                contentObjects.append(.text(text))
            case .image(let mimeType, let data):
                let imageSource = MessageParameter.Message.Content.ImageSource(
                    type: .base64,
                    mediaType: .init(rawValue: mimeType) ?? .jpeg,
                    data: data.base64EncodedString()
                )
                contentObjects.append(.image(imageSource))
            }
        }
        
        let finalContent: MessageParameter.Message = .init(
            role: conversation.role.toClaudeRole(),
            content: .list(contentObjects)
        )
        
        return finalContent
    }
    
    static func refreshModels(provider: Provider) async -> [GenericModel] {
        return provider.type.getDefaultModels().map { model in
            GenericModel(code: model.code, name: model.name)
        }
    }
    
    static func streamResponse(from conversations: [Message], config: ChatConfig) -> AsyncThrowingStream<StreamResponse, Error> {
        let parameters = createParameters(from: conversations, config: config, stream: true)
        let service = getService(provider: config.provider)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let response = try await service.streamMessage(parameters)
                    for try await result in response {
                        if let content = result.delta?.text {
                            continuation.yield(.content(content))
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    static func nonStreamingResponse(from conversations: [Message], config: ChatConfig) async throws -> NonStreamResponse {
        let parameters = createParameters(from: conversations, config: config, stream: false)
        let service = getService(provider: config.provider)
        
        let message = try await service.createMessage(parameters)
        // Extract the text content from the message
        let content = message.content.compactMap { content -> String? in
            switch content {
            case .text(let text):
                return text
            case .toolUse:
                return nil // TODO: claude toolCalls
            }
        }.joined()
        
        return NonStreamResponse(content: content, toolCalls: nil, inputTokens: 0, outputTokens: 0)
    }
    
    static private func createParameters(from conversations: [Message], config: ChatConfig, stream: Bool) -> MessageParameter {
        let messages = conversations.map { convert(conversation: $0) }
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
    
    static func testModel(provider: Provider, model: AIModel) async -> Bool {
        let betaHeaders = ["prompt-caching-2024-07-31", "max-tokens-3-5-sonnet-2024-07-15"]
        let service = AnthropicServiceFactory.service(
            apiKey: provider.apiKey,
            basePath: provider.scheme.rawValue + "://" + provider.host, betaHeaders: betaHeaders)
        
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
    
    static func getService(provider: Provider) -> AnthropicService {
        let betaHeaders = ["prompt-caching-2024-07-31", "max-tokens-3-5-sonnet-2024-07-15"]
        return AnthropicServiceFactory.service(
            apiKey: provider.apiKey,
            basePath: provider.scheme.rawValue + "://" + provider.host, betaHeaders: betaHeaders)
    }
}
