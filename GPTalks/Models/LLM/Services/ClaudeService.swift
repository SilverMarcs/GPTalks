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
        var localRole = conversation.role.toClaudeRole()
        
        let contentItems = FileHelper.processDataFiles(conversation.dataFiles, messageId: conversation.id.uuidString, role: conversation.role)
        var contentObjects: [MessageParameter.Message.Content.ContentObject] = []
        for item in contentItems {
            switch item {
            case .text(let text):
                if conversation.useCache {
                    contentObjects.append(.cache(.init(text: text, cacheControl: .init(type: .ephemeral))))
                } else {
                    contentObjects.append(.text(text))
                }
            case .image(let mimeType, let data):
                let imageSource = MessageParameter.Message.Content.ImageSource(
                    type: .base64,
                    mediaType: .init(rawValue: mimeType) ?? .jpeg,
                    data: data.base64EncodedString()
                )
                contentObjects.append(.image(imageSource))
            }
        }
        
        if !conversation.content.isEmpty {
            if conversation.useCache {
                contentObjects.append(.cache(.init(text: conversation.content, cacheControl: .init(type: .ephemeral))))
            } else {
                contentObjects.append(.text(conversation.content))
            }
        }
        
        if let response = conversation.toolResponse {
            localRole = .user
            contentObjects.append(.toolResult(response.tool.toolName, "See next message"))
            if conversation.useCache {
                contentObjects.append(.cache(.init(text: response.processedContent, cacheControl: .init(type: .ephemeral))))
            } else {
                contentObjects.append(.text(response.processedContent))
            }
        }
        
        for call in conversation.toolCalls {
            print("Conversion ToolCallId: \(call.toolCallId)")
            contentObjects.append(.toolUse(call.tool.toolName, call.toolCallId, ["arguments": .string(call.arguments)]))
        }
        
        let finalContent: MessageParameter.Message = .init(
            role: localRole,
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
        print("doing ANTHROPIC stream")
        let parameters = createParameters(from: conversations, config: config, stream: true)
        let service = getService(provider: config.provider)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let response = try await service.streamMessage(parameters)
                    var currentToolUseId: String?
                    var currentToolName: String?
                    var partialJsonAccumulator = ""
                    var inputTokens = 0
                    var outputTokens = 0

                    for try await result in response {
                        let content = result.delta?.text ?? ""
                        continuation.yield(.content(content))
                        
                        if let streamEvent = result.streamEvent {
                            switch streamEvent {
                            case .messageStart:
                                // Capture input tokens at the beginning
                                if let usage = result.message?.usage {
                                    inputTokens = usage.inputTokens ?? 0
                                }

                            case .contentBlockStart:
                                if let toolUse = result.contentBlock?.toolUse {
                                    // Start accumulating JSON for this tool use
                                    currentToolUseId = toolUse.id
                                    currentToolName = toolUse.name
                                    partialJsonAccumulator = ""
                                }
                                
                            case .contentBlockDelta:
                                // Continue accumulating partial JSON data
                                if let partialJson = result.delta?.partialJson {
                                    partialJsonAccumulator += partialJson
                                }
                                
                            case .contentBlockStop:
                                // Finalize the tool call when the content block stops
                                if let toolId = currentToolUseId, let toolName = currentToolName {
                                    // Use the accumulated JSON
                                    let argumentsString = partialJsonAccumulator

                                    // Create the ChatToolCall object
                                    let call = ChatToolCall(
                                        toolCallId: toolId,
                                        tool: ChatTool(rawValue: toolName)!,
                                        arguments: argumentsString
                                    )
                                    
                                    continuation.yield(.toolCalls([call]))
                                    
                                    // Reset the accumulator and current tool information
                                    currentToolUseId = nil
                                    currentToolName = nil
                                    partialJsonAccumulator = ""
                                }
                                
                            case .messageDelta:
                                // Capture output tokens at the end
                                if let usage = result.usage {
                                    outputTokens = usage.outputTokens
                                }
                                
                            case .messageStop:
                                // Sum input and output tokens and yield as output tokens
                                let totalTokens = TokenUsage(inputTokens: inputTokens, outputTokens: outputTokens)
                                continuation.yield(.totalTokens(totalTokens))
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    print(error)
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    static func nonStreamingResponse(from conversations: [Message], config: ChatConfig) async throws -> NonStreamResponse {
        print("doing ANTHROPIC NON stream")
        let parameters = createParameters(from: conversations, config: config, stream: false)
        let service = getService(provider: config.provider)
        
        let message = try await service.createMessage(parameters)
        // Extract the text content from the message
        let (content, toolCalls) = message.content.reduce(("", [ChatToolCall]())) { (result, content) -> (String, [ChatToolCall]) in
              var (currentContent, currentToolCalls) = result
              switch content {
              case .text(let text):
                  currentContent += text
              case .toolUse(let toolUse):
                  // Extract tool name and arguments from toolUse
                  let toolName = toolUse.name
                  
                  // Convert the input dictionary to a string representation of arguments
                  let argumentsString = convertToString(toolUse.input)
                  
                  // Create ChatToolCall
                  let call = ChatToolCall(
                      toolCallId: toolUse.id,
                      tool: ChatTool(rawValue: toolName)!,
                      arguments: argumentsString
                  )
                  currentToolCalls.append(call)
              }
              return (currentContent, currentToolCalls)
          }
          
          return NonStreamResponse(content: content, toolCalls: toolCalls.isEmpty ? nil : toolCalls, inputTokens: message.usage.inputTokens ?? 0, outputTokens: message.usage.outputTokens)
    }
    
    static private func createParameters(from conversations: [Message], config: ChatConfig, stream: Bool) -> MessageParameter {
        let messages = conversations.map { convert(conversation: $0) }
        let systemPrompt = MessageParameter.System.text(config.systemPrompt)
        let tools = config.tools.enabledTools.map { $0.anthropic }
        
        return MessageParameter(
            model: .other(config.model.code),
            messages: messages,
            maxTokens: config.maxTokens ?? 4096,
            system: systemPrompt,
            stream: stream,
            temperature: config.temperature,
            topP: config.topP,
            tools: tools.isEmpty ? nil : tools
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

func convertToString(_ input: [String: MessageResponse.Content.DynamicContent]) -> String {
    var result = ""
    do {
        let jsonData = try JSONEncoder().encode(input)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            result = jsonString
        }
    } catch {
        print("Error converting dictionary to JSON string: \(error)")
    }
    
    return result
}
