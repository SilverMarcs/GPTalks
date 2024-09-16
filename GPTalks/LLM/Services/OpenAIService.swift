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
    
    static func refreshModels(provider: Provider) async -> [AIModel] {
        let service = OpenAI(configuration: OpenAI.Configuration(token: provider.apiKey, host: provider.host, scheme: provider.type.scheme))
        
        do {
            let result = try await service.models()
            return result.data.map { AIModel(code: $0.id, name: $0.name) }
        } catch {
            return []
        }
    }
    
    static func convert(conversation: Conversation) -> ConvertedType {
        let role = conversation.role.toOpenAIRole()
        
        if !conversation.toolCalls.isEmpty {
            return .init(
                role: .assistant, // should always be .assistant here
                toolCalls: conversation.toolCalls.map { toolCall in
                        .init(id: toolCall.toolCallId, function: .init(arguments: toolCall.arguments, name: toolCall.tool.rawValue))
                    }
                )!
        }
        
        if let toolResponse = conversation.toolResponse {
            return .init(
                role: .tool, // should always be .tool here
                content: toolResponse.processedContent,
                name: toolResponse.tool.rawValue,
                toolCallId: toolResponse.toolCallId
            )!
        }
        
        if conversation.dataFiles.isEmpty {
            return ChatQuery.ChatCompletionMessageParam(
                role: role,
                content: conversation.content
            )!
        }
        
        let processedContents = ContentHelper.processDataFiles(conversation.dataFiles, conversationContent: conversation.content)
        
        var visionContent: [ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content.VisionContent] = []
        
        for content in processedContents {
            switch content {
            case .image(let mimeType, let base64Data):
                let url = "data:image/jpeg;base64,\(base64Data)"
                visionContent.append(.init(chatCompletionContentPartImageParam: .init(imageUrl: .init(url: url, detail: .auto))))
            case .text(let text):
                visionContent.append(.init(chatCompletionContentPartTextParam: .init(text: text)))
            }
        }
        
        return ChatQuery.ChatCompletionMessageParam(
            role: .user, // vision content can only be on user role
            content: visionContent
        )!
    }
    
    static func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<StreamResponse, Error> {
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
            messages.insert(convert(conversation: systemPrompt), at: 0)
        }
        
        let tools = config.tools.enabledTools.map { $0.openai }
    
        return ChatQuery(
            messages: messages,
            model: config.model.code,
            frequencyPenalty: config.frequencyPenalty,
            maxTokens: config.maxTokens,
            presencePenalty: config.presencePenalty,
            temperature: config.temperature,
            tools: tools.isEmpty ? nil : tools,
            topP: config.topP,
            stream: stream
        )
    }
    
    static func streamOpenAIResponse(query: ChatQuery, config: SessionConfig) -> AsyncThrowingStream<StreamResponse, Error> {
        let service = OpenAI(configuration: OpenAI.Configuration(token: config.provider.apiKey, host: config.provider.host, scheme: config.provider.type.scheme))
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var currentToolCalls: [ToolCall] = []
                    
                    for try await result in service.chatsStream(query: query) {
                        if let toolCallsDelta = result.choices.first?.delta.toolCalls {
                            for toolCallDelta in toolCallsDelta {
                                let index = toolCallDelta.index
                                
                                if currentToolCalls.count <= index {
                                    if let tool = ChatTool(rawValue: toolCallDelta.function?.name ?? "") {
                                        currentToolCalls.append(ToolCall(toolCallId: toolCallDelta.id ?? "", tool: tool, arguments: ""))
                                    }
                                }
                                
                                if let name = toolCallDelta.function?.name, let tool = ChatTool(rawValue: name) {
                                    currentToolCalls[index].tool = tool
                                }
                                
                                if let arguments = toolCallDelta.function?.arguments {
                                    currentToolCalls[index].arguments += arguments
                                }
                            }
                            
                            if result.choices.first?.finishReason == .toolCalls {
                                continuation.yield(.toolCalls(currentToolCalls))
                            }
                        } else if let content = result.choices.first?.delta.content, !content.isEmpty {
                            continuation.yield(.content(content))
                        }
                    }
                    
                    if !currentToolCalls.isEmpty {
                        continuation.yield(.toolCalls(currentToolCalls))
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
        print("result \(result)")
        
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
