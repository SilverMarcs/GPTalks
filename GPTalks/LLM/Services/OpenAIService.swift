//
//  OpenAIService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import Foundation
import SwiftUI
import SwiftOpenAI

struct OpenAIService: AIService {
    typealias ConvertedType = ChatCompletionParameters.Message
    
    static func refreshModels(provider: Provider) async -> [ChatModel] {
        let service = getService(provider: provider)
        
        do {
            let result = try await service.listModels()
            return result.data.map { ChatModel(code: $0.id, name: $0.id.capitalized) }
        } catch {
            return []
        }
    }
    
    static func convert(conversation: Conversation) -> ConvertedType {
        let role = conversation.role.toOpenAIRole()
        
        var contents: [ChatCompletionParameters.Message.ContentType.MessageContent] = []
        var toolCalls: [ToolCall]?
        var toolCallID: String?

        switch role {
        case .user where !conversation.dataFiles.isEmpty:
            contents.append(.text(conversation.content))
            
            for data in conversation.dataFiles {
                if data.fileType.conforms(to: .image) {
                    let url = "data:image/jpeg;base64,\(data.data.base64EncodedString())"
                    contents.append(.imageUrl(.init(url: URL(string: url)!)))
                } else {
                    contents.append(.text("Conversation ID: \(conversation.id)\nFile: \(data.fileName).\(data.fileExtension)"))
                }
            }
        
        case .user:
            contents.append(.text(conversation.content))
            
        case .assistant where !conversation.toolCalls.isEmpty:
            toolCalls = conversation.toolCalls.map { toolCall in
                .init(id: toolCall.toolCallId, function: .init(arguments: toolCall.arguments, name: toolCall.tool.rawValue))
            }

        case .assistant:
            contents.append(.text(conversation.content))

        case .tool:
            toolCallID = conversation.toolResponse!.toolCallId  // should not be created with nil value to begin with thus force unwrapping
            contents.append(.text(conversation.toolResponse!.processedContent))

        case .system:
            contents.append(.text(conversation.content))
        }

        return .init(role: role, content: .contentArray(contents), toolCalls: toolCalls, toolCallID: toolCallID)
    }
    
    static func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<StreamResponse, Error> {
        let query = createQuery(from: conversations, config: config, stream: config.stream)
        return streamOpenAIResponse(query: query, config: config)
    }
    
    static func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> StreamResponse {
        let query = createQuery(from: conversations, config: config, stream: config.stream)
        return try await nonStreamingOpenAIResponse(query: query, config: config)
    }
    
    static func createQuery(from conversations: [Conversation], config: SessionConfig, stream: Bool) -> ChatCompletionParameters {
        var messages = conversations.map { convert(conversation: $0) }
        if !config.systemPrompt.isEmpty {
            let systemPrompt = Conversation(role: .system, content: config.systemPrompt)
            messages.insert(convert(conversation: systemPrompt), at: 0)
        }
        
        let tools = config.tools.enabledTools.map { $0.openai }
    
        return .init(
            messages: messages,
            model: .custom(config.model.code),
            frequencyPenalty: config.frequencyPenalty,
            tools: tools.isEmpty ? nil : tools,
            maxTokens: config.maxTokens,
            presencePenalty: config.presencePenalty,
            temperature: config.temperature
        )
    }
    
    static func streamOpenAIResponse(query: ChatCompletionParameters, config: SessionConfig) -> AsyncThrowingStream<StreamResponse, Error> {
        let service = getService(provider: config.provider)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var currentToolCalls: [Int: ChatToolCall] = [:]
                    for try await result in try await service.startStreamedChat(parameters: query) {
                        if let choice = result.choices.first {
                            if let toolCalls = choice.delta.toolCalls {
                                for toolCall in toolCalls {
                                    let index = toolCall.index ?? 0
                                    
                                    if var existingToolCall = currentToolCalls[index] {
                                        // Append new arguments to existing tool call
                                        existingToolCall.arguments += toolCall.function.arguments
                                        currentToolCalls[index] = existingToolCall
                                    } else {
                                        // Create new tool call
                                        if let chatTool = ChatTool(rawValue: toolCall.function.name ?? "") {
                                            let newToolCall = ChatToolCall(
                                                toolCallId: toolCall.id ?? UUID().uuidString,
                                                tool: chatTool,
                                                arguments: toolCall.function.arguments
                                            )
                                            currentToolCalls[index] = newToolCall
                                        }
                                    }
                                }
                            }
                            
                            if let newContent = choice.delta.content {
                                continuation.yield(.content(newContent))
                            }
                        }
                    }
                    
                    if !currentToolCalls.isEmpty {
                        continuation.yield(.toolCalls(Array(currentToolCalls.values)))
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    static func nonStreamingOpenAIResponse(query: ChatCompletionParameters, config: SessionConfig) async throws -> StreamResponse {
        let service = getService(provider: config.provider)
        
        let result = try await service.startChat(parameters: query)
        
        if let choice = result.choices.first {
            if let toolCalls = choice.message.toolCalls {
                return .toolCalls(toolCalls.map { toolCall in
                    ChatToolCall(
                        toolCallId: toolCall.id ?? UUID().uuidString,
                        tool: ChatTool(rawValue: toolCall.function.name ?? "")!,
                        arguments: toolCall.function.arguments
                    )
                })
            } else if let newContent = choice.message.content {
                return .content(newContent)
            }
        }
        
        #warning("Should never reach here.")
        return .content("No content or tool calls available.")
    }
    
    static func testModel(provider: Provider, model: ChatModel) async -> Bool {
        let service = getService(provider: provider)
        let messages = [convert(conversation: Conversation(role: .user, content: String.testPrompt))]
        let query = ChatCompletionParameters(messages: messages, model: .custom(model.code))
        
        do {
            let result = try await service.startChat(parameters: query)
            return result.choices.first?.message.content != nil
        } catch {
            return false
        }
    }
    
    static func getService(provider: Provider) -> SwiftOpenAI.OpenAIService {
        return OpenAIServiceFactory.service(apiKey: provider.apiKey, baseURL: "\(provider.type.scheme)://\(provider.host)", debugEnabled: false)
    }
}
