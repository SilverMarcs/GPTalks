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
    
    static func refreshModels(provider: Provider) async -> [GenericModel] {
        let service = getService(provider: provider)
        
        do {
            let result = try await service.models()
            let sortedModels = result.data
                .map { GenericModel(code: $0.id, name: $0.name) }
                .sorted { $0.name < $1.name }
            return sortedModels
        } catch {
            return []
        }
    }
    
    static func convert(conversation: Conversation) -> ConvertedType {
        let role = conversation.role.toOpenAIRole()

        switch role {
        case .user where !conversation.dataFiles.isEmpty:
            var contents: [ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content.VisionContent] = []
            
            contents.append(.init(chatCompletionContentPartTextParam: .init(text: conversation.content)))
            for data in conversation.dataFiles {
                if data.fileType.conforms(to: .image) {
                    let url = "data:image/jpeg;base64,\(data.data.base64EncodedString())"
                    contents.append(.init(chatCompletionContentPartImageParam: .init(imageUrl: .init(url: url, detail: .low))))
                } else {
                    let warning = "Notify the user if a file has been added but the assistant could not find a compatible plugin to read that file type."
                    contents.append(.init(chatCompletionContentPartTextParam: .init(text: "Conversation ID: \(conversation.id)\nFile: \(data.fileName)\n\(warning)")))
                }
            }
            
            return ChatQuery.ChatCompletionMessageParam(
                role: role, // vision content can only be on user role
                content: contents
            )!
        
        case .user:
            return ChatQuery.ChatCompletionMessageParam(
                role: role,
                content: conversation.content
            )!
            
        case .assistant where !conversation.toolCalls.isEmpty:
            return .init(
                role: role,
                toolCalls: conversation.toolCalls.map { toolCall in
                        .init(id: toolCall.toolCallId, function: .init(arguments: toolCall.arguments, name: toolCall.tool.rawValue))
                    }
                )!

        case .assistant:
            return ChatQuery.ChatCompletionMessageParam(
                role: role,
                content: conversation.content
            )!

        case .tool:
            if let toolResponse = conversation.toolResponse {
                return .init(
                    role: role,
                    content: toolResponse.processedContent,
                    name: toolResponse.tool.rawValue,
                    toolCallId: toolResponse.toolCallId
                )!
            } else {
                return .init(
                    role: role,
                    content: "Unable to call Tool. Notify the user",
                    toolCallId: "Unknowne"
                )!
            }

        case .system:
            return ChatQuery.ChatCompletionMessageParam(
                role: role,
                content: conversation.content
            )!
        }
    }
    
    static func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<StreamResponse, Error> {
        let query = createQuery(from: conversations, config: config, stream: config.stream)
        return streamOpenAIResponse(query: query, config: config)
    }
    
    static func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> StreamResponse {
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
        let service = getService(provider: config.provider)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var currentToolCalls: [ChatToolCall] = []
                    
                    for try await result in service.chatsStream(query: query) {
                        if let toolCallsDelta = result.choices.first?.delta.toolCalls {
                            for toolCallDelta in toolCallsDelta {
                                let index = toolCallDelta.index
                                
                                if currentToolCalls.count <= index {
                                    if let tool = ChatTool(rawValue: toolCallDelta.function?.name ?? "") {
                                        currentToolCalls.append(ChatToolCall(toolCallId: toolCallDelta.id ?? "", tool: tool, arguments: ""))
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
    
    static func nonStreamingOpenAIResponse(query: ChatQuery, config: SessionConfig) async throws -> StreamResponse {
        let service = getService(provider: config.provider)
        
        let result = try await service.chats(query: query)
        if let content = result.choices.first?.message.content?.string {
            return .content(content)
        } else if let tools = result.choices.first?.message.toolCalls, tools.count > 0 {
            // Create toolCalls from tools
            let toolCalls = tools.map { tool in
                ChatToolCall(toolCallId: tool.id, tool: ChatTool(rawValue: tool.function.name)!, arguments: tool.function.arguments)
            }
            
            return .toolCalls(toolCalls)
        } else {
            // Add a default return statement to handle all cases
            return .content("No content or tool calls available.")
        }
    }
    
    static func testModel(provider: Provider, model: any ModelType) async -> Bool {
        let service = getService(provider: provider)
        
        let messages = [convert(conversation: Conversation(role: .user, content: String.testPrompt))]
        let query = ChatQuery(messages: messages, model: model.code)
        
        do {
            let result = try await service.chats(query: query)
            return result.choices.first?.message.content?.string != nil
        } catch {
            return false
        }
    }
    
    static func getService(provider: Provider) -> OpenAI {
        return OpenAI(configuration: OpenAI.Configuration(token: provider.apiKey, host: provider.host, scheme: provider.scheme.rawValue))
    }
}
