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
    
    static func convert(conversation: Message) -> ConvertedType {
        let role = conversation.role.toOpenAIRole()

        switch role {
        case .user where !conversation.dataFiles.isEmpty:            
            let contentItems = FileHelper.processDataFiles(conversation.dataFiles, messageId: conversation.id.uuidString, role: conversation.role)
            var contents: [ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content.VisionContent] = []
            contents.append(.init(chatCompletionContentPartTextParam: .init(text: conversation.content)))
            for item in contentItems {
                switch item {
                case .text(let text):
                    contents.append(.init(chatCompletionContentPartTextParam: .init(text: text)))
                case .image(let mimeType, let data):
                    let url = "data:\(mimeType);base64,\(data.base64EncodedString())"
                    contents.append(.init(chatCompletionContentPartImageParam: .init(imageUrl: .init(url: url, detail: .low))))
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
    
    static func streamResponse(from conversations: [Message], config: ChatConfig) -> AsyncThrowingStream<StreamResponse, Error> {
        let query = createQuery(from: conversations, config: config, stream: config.stream)
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
                        } else if let usage = result.usage {
                            continuation.yield(.outputTokens(usage.totalTokens))
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
    
    static func nonStreamingResponse(from conversations: [Message], config: ChatConfig) async throws -> NonStreamResponse {
        let query = createQuery(from: conversations, config: config, stream: config.stream)
        let service = getService(provider: config.provider)
        
        let result = try await service.chats(query: query)
        
        let content = result.choices.first?.message.content?.string
        var toolCalls: [ChatToolCall]? = nil
        
        if let tools = result.choices.first?.message.toolCalls, !tools.isEmpty {
            toolCalls = tools.map { tool in
                ChatToolCall(toolCallId: tool.id, tool: ChatTool(rawValue: tool.function.name)!, arguments: tool.function.arguments)
            }
        }
        
        return NonStreamResponse(
            content: content,
            toolCalls: toolCalls,
            inputTokens: result.usage?.promptTokens ?? 0,
            outputTokens: result.usage?.completionTokens ?? 0
        )
    }
    
    static func createQuery(from conversations: [Message], config: ChatConfig, stream: Bool) -> ChatQuery {
        var messages = conversations.map { convert(conversation: $0) }
        if !config.systemPrompt.isEmpty {
            let systemPrompt = Message(role: .system, content: config.systemPrompt)
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
            stream: stream,
            streamOptions: config.stream ? .init(includeUsage: true) : nil
        )
    }
    
    static func testModel(provider: Provider, model: AIModel) async -> Bool {
        let service = getService(provider: provider)
        
        let messages = [convert(conversation: Message(role: .user, content: String.testPrompt))]
        let query = ChatQuery(messages: messages, model: model.code)
        
        do {
            let result = try await service.chats(query: query)
            return result.choices.first?.message.content?.string != nil
        } catch {
            print("Model test error: \(error)")
            return false
        }
    }
    
    static func getService(provider: Provider) -> OpenAI {
        return OpenAI(configuration: OpenAI.Configuration(token: provider.apiKey, host: provider.host, scheme: provider.scheme.rawValue))
    }
}
