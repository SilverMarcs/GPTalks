//
//  GoogleService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import Foundation
import SwiftUI
import GoogleGenerativeAI

struct GoogleService: AIService {
    typealias ConvertedType = ModelContent
    
    static func refreshModels(provider: Provider) async -> [GenericModel] {
        let service = GenerativeAIService(apiKey: provider.apiKey, urlSession: .shared)
        
        do {
            let models = try await service.listModels()
            return models.models.map { GenericModel(code: $0.name, name: $0.displayName ?? $0.name) }
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    static func convert(conversation: Thread) -> GoogleGenerativeAI.ModelContent {
        var parts: [ModelContent.Part] = [.text(conversation.content)]
        
        for dataFile in conversation.dataFiles {
            if dataFile.fileType.conforms(to: .text) {
                parts.insert(.text(String(data: dataFile.data, encoding: .utf8) ?? ""), at: 0)
            } else {
                parts.insert(.data(mimetype: dataFile.mimeType, dataFile.data), at: 0)
            }
        }
        
        // TODO: see if can send image here
        if let response = conversation.toolResponse {
            parts.append(.functionResponse(.init(name: response.tool.rawValue, response: .init(dictionaryLiteral: ("content", .string(response.processedContent))))))
        }
        
        return ModelContent(
            role: conversation.role.toGoogleRole(),
            parts: parts
        )
    }
    
    static func streamResponse(from conversations: [Thread], config: ChatConfig) -> AsyncThrowingStream<StreamResponse, Error> {
        let (model, messages) = createModelAndMessages(from: conversations, config: config)
        return streamGoogleResponse(model: model, messages: messages)
    }
    
    static func nonStreamingResponse(from conversations: [Thread], config: ChatConfig) async throws -> NonStreamResponse {
        let (model, messages) = createModelAndMessages(from: conversations, config: config)
        let response = try await model.generateContent(messages)
        let toolCalls = response.functionCalls.map {
            ChatToolCall(toolCallId: "",
                         tool: ChatTool(rawValue: $0.name)!,
                         arguments: encodeJSONObjectToString($0.args))
        }
        
        // TODO: do token count
        return NonStreamResponse(content: response.text, toolCalls: toolCalls, inputTokens: 0, outputTokens: 0)
    }
    
    static private func createModelAndMessages(from conversations: [Thread], config: ChatConfig) -> (GenerativeModel, [ModelContent]) {
        let systemPrompt = ModelContent(role: "system", parts: [.text(config.systemPrompt)])
        
        let genConfig = GenerationConfig(
            temperature: config.temperature.map { Float($0) },
            topP: config.topP.map { Float($0) },
            maxOutputTokens: config.maxTokens
        )
        
        var tools = config.tools.enabledTools.map { $0.google }
        
        if config.tools.googleCodeExecution {
            tools.append(Tool(codeExecution: .init()))
        }
        
        if config.tools.googleSearchRetrieval {
            tools.append(Tool(googleSearchRetrieval: .init()))
        }
        
        let model = GenerativeModel(
            name: config.model.code,
            apiKey: config.provider.apiKey,
            generationConfig: genConfig,
            tools: tools.isEmpty ? nil : tools,
            systemInstruction: systemPrompt)
        
        let messages = conversations.map { convert(conversation: $0) }
        
        return (model, messages)
    }
    
    static private func streamGoogleResponse(model: GenerativeModel, messages: [ModelContent]) -> AsyncThrowingStream<StreamResponse, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let responseStream = model.generateContentStream(messages)
                    
                    for try await response in responseStream {
                        if let candidate = response.candidates.first {
                            for part in candidate.content.parts {
                                switch part {
                                case .executableCode(let executableCode):
                                    let codeBlockLanguage = executableCode.language == "LANGUAGE_UNSPECIFIED" ? "" : executableCode.language.lowercased()
                                    let formattedCode = "**Code to execute:**\n```\(codeBlockLanguage)\(executableCode.code)```\n"
                                    continuation.yield(.content(formattedCode))
                                case .codeExecutionResult(let codeExecutionResult):
                                    if !codeExecutionResult.output.isEmpty {
                                        let formattedOutput = "**Code Output:**\n```\n\(codeExecutionResult.output)```\n"
                                        continuation.yield(.content(formattedOutput))
                                    }
                                case .functionCall(let functionCall):
                                    print("Function call: \(functionCall.name)")
                                    let call = ChatToolCall(toolCallId: "",
                                                            tool: ChatTool(rawValue: functionCall.name)!,
                                                            arguments: encodeJSONObjectToString(functionCall.args))
                                    continuation.yield(.toolCalls([call]))
                                case .text(let text):
                                    continuation.yield(.content(text))
                                case .data, .fileData, .functionResponse:
                                    print("Data, file data, and function response are not supported")
                                    break
                                }
                            }
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    static private func nonStreamingGoogleResponse(model: GenerativeModel, messages: [ModelContent]) async throws -> StreamResponse {
        let response = try await model.generateContent(messages)
        return .content(response.text ?? "")
    }
    
    static func testModel(provider: Provider, model: AIModel) async -> Bool {
        let model = GenerativeModel(name: model.code, apiKey: provider.apiKey)
        
        do {
            let response = try await model.generateContent(String.testPrompt)
            return response.text != nil
        } catch {
            return false
        }
    }
}

func encodeJSONObjectToString(_ jsonObject: JSONObject) -> String {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(jsonObject)
        if let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        } else {
            return "{}" // Return empty object as fallback
        }
    } catch {
        print("Error encoding JSON: \(error)")
        return "{}" // Return empty object in case of error
    }
}
