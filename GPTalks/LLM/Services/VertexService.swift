//
//  VertexService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/09/2024.
//

import Foundation
import GoogleSignIn

struct VertexService: AIService {
    typealias ConvertedType = [String: Any]
    
    static func refreshModels(provider: Provider) async -> [AIModel] {
        return provider.type.getDefaultModels()
    }
    
    static func convert(conversation: Conversation) -> [String: Any] {
        let role = conversation.role.toVertexRole()
        let processedContents = ContentHelper.processDataFiles(conversation.dataFiles, conversationContent: conversation.content)
        
        var contentObjects: [[String: Any]] = []
        
        for content in processedContents {
            switch content {
            case .image(let mimeType, let base64Data):
                let imageContent: [String: Any] = [
                    "type": "image",
                    "source": [
                        "type": "base64",
                        "media_type": mimeType,
                        "data": base64Data
                    ]
                ]
                contentObjects.append(imageContent)
            case .text(let text):
                if !text.isEmpty {
                    contentObjects.append([
                        "type": "text",
                        "text": text
                    ])
                }
            }
        }
        
        for toolCall in conversation.toolCalls {
            // Clean up the JSON string
            let cleanedArguments = toolCall.arguments.replacingOccurrences(of: "\\", with: "")
            
            // Parse the cleaned JSON string
            if let jsonData = cleanedArguments.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                
                let toolContent: [String: Any] = [
                    "type": "tool_use",
                    "name": toolCall.tool.rawValue,
                    "id": toolCall.toolCallId,
                    "input": jsonObject
                ]
                contentObjects.append(toolContent)
            } else {
                print("Failed to parse tool call arguments: \(toolCall.arguments)")
            }
        }
        
        if let toolResponse = conversation.toolResponse {
            // TODO: can send image here also
            let toolResponseContent: [String: Any] = [
                "type": "tool_result",
                "content": toolResponse.processedContent,
                "tool_use_id": toolResponse.toolCallId,
            ]
            contentObjects.append(toolResponseContent)
        }
        
        let finalContent: [String: Any] = [
            "role": role,
            "content": contentObjects
        ]
        
        return finalContent
    }
    
    static func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<StreamResponse, any Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let request = try await createRequest(from: conversations, config: config)
                    let (asyncBytes, _) = try await URLSession.shared.bytes(for: request)
                    
                    var buffer = ""
                    var toolCalls: [[String: Any]] = []
                    var isToolUse = false
                    
                    for try await byte in asyncBytes {
                        if let character = String(bytes: [byte], encoding: .utf8) {
                            buffer += character
                            if character == "\n" {
                                print("Received data: \(buffer)")
                                
                                if buffer.hasPrefix("data: ") {
                                    let jsonString = buffer.dropFirst(6)
                                    print("JSON string: \(jsonString)")
                                    
                                    if let jsonData = jsonString.data(using: .utf8),
                                       let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                        print("Parsed JSON object: \(jsonObject)")
                                        
                                        if let type = jsonObject["type"] as? String {
                                            switch type {
                                            case "content_block_start":
                                                if let contentBlock = jsonObject["content_block"] as? [String: Any],
                                                   contentBlock["type"] as? String == "tool_use" {
                                                    isToolUse = true
                                                    toolCalls.append(contentBlock)
                                                }
                                            case "content_block_delta":
                                                if isToolUse {
                                                    if let delta = jsonObject["delta"] as? [String: Any],
                                                       let partialJson = delta["partial_json"] as? String {
                                                        toolCalls[toolCalls.count - 1]["input"] = (toolCalls[toolCalls.count - 1]["input"] as? String ?? "") + partialJson
                                                    }
                                                } else if let delta = jsonObject["delta"] as? [String: Any],
                                                          let text = delta["text"] as? String {
                                                    continuation.yield(.content(text))
                                                }
                                            case "content_block_stop":
                                                if isToolUse {
                                                    isToolUse = false
                                                }
                                            case "message_stop":
                                                if !toolCalls.isEmpty {
                                                    let calls: [ToolCall] = toolCalls.map {
                                                        ToolCall(toolCallId: $0["id"] as? String ?? "",
                                                                 tool: ChatTool(rawValue: $0["name"] as? String ?? "")!,
                                                                 arguments: $0["input"] as? String ?? "")
                                                    }
                                                    continuation.yield(.toolCalls(calls))
                                                    toolCalls.removeAll()
                                                }
                                            default:
                                                break
                                            }
                                        } else {
                                            throw URLError(.cannotParseResponse)
                                        }
                                    } else {
                                        throw URLError(.cannotParseResponse)
                                    }
                                }
                                buffer = ""
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

    static func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> StreamResponse {
        let request = try await createRequest(from: conversations, config: config)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let contentArray = jsonObject["content"] as? [[String: Any]] else {
            throw URLError(.cannotParseResponse)
        }
        
        let text = contentArray.compactMap { $0["text"] as? String }.joined(separator: " ")
        return .content(text)
    }

    static func createRequest(from conversations: [Conversation], config: SessionConfig) async throws -> URLRequest {
        let modelID = config.model.code
        let projectID = config.provider.host
        let location = "us-east5"
        let apiUrl = "https://\(location)-aiplatform.googleapis.com/v1/projects/\(projectID)/locations/\(location)/publishers/anthropic/models/\(modelID):streamRawPredict"
        
        guard let url = URL(string: apiUrl) else {
            throw URLError(.badURL)
        }
        
        print("API URL: \(apiUrl)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let token = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            currentUser.refreshTokensIfNeeded { user, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let user = user else {
                    continuation.resume(throwing: URLError(.userAuthenticationRequired))
                    return
                }
                continuation.resume(returning: user.accessToken.tokenString)
            }
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let messages: [[String: Any]] = conversations.map { conversation in
            return convert(conversation: conversation)
        }
        

        var body: [String: Any] = [
            "anthropic_version": "vertex-2023-10-16",
            "messages": messages,
            "max_tokens": config.maxTokens ?? 4096,
            "temperature": config.temperature ?? 1.0,
            "stream": config.stream
        ]
        let tools = config.tools.enabledTools.map { $0.vertex }
        if !tools.isEmpty {
            body["tools"] = tools
        }

        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        return request
    }
    
    static func testModel(provider: Provider, model: AIModel) async -> Bool {
        return false
    }
}
