//
//  VertexService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/09/2024.
//

import Foundation

struct VertexService: AIService {
    typealias ConvertedType = [String: Any]
    
    static func refreshModels(provider: Provider) async -> [GenericModel] {
        return provider.type.getDefaultModels().map { model in
            GenericModel(code: model.code, name: model.name)
        }
    }
    
    static func convert(conversation: Thread) -> [String: Any] {
        let role = conversation.role.toVertexRole()
        
        var contentObjects: [[String: Any]] = []
        
        if let toolResponse = conversation.toolResponse {
            let toolResponseContent: [String: Any] = [
                "type": "tool_result",
                "content": toolResponse.processedContent,
                "tool_use_id": toolResponse.toolCallId,
            ]
            contentObjects.append(toolResponseContent)
        }
        
        if !conversation.content.isEmpty {
            contentObjects.append([
                "type": "text",
                "text": conversation.content
            ])
        }
        
        let contentItems = FileHelper.processDataFiles(conversation.dataFiles, threadId: conversation.id.uuidString, role: conversation.role)
        for item in contentItems {
            switch item {
            case .text(let text):
                contentObjects.append([
                    "type": "text",
                    "text": text
                ])
            case .image(let mimeType, let data):
                contentObjects.append([
                    "type": "image",
                    "source": [
                        "type": "base64",
                        "media_type": mimeType,
                        "data": data.base64EncodedString()
                    ]
                ])
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
                
        let finalContent: [String: Any] = [
            "role": role,
            "content": contentObjects
        ]
        
        return finalContent
    }
    
    static func streamResponse(from conversations: [Thread], config: ChatConfig) -> AsyncThrowingStream<StreamResponse, any Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var inputTokens = 0
                    var outputTokens = 0
                    
                    let request = try await createRequest(from: conversations, config: config)
                    let (asyncBytes, _) = try await URLSession.shared.bytes(for: request)
                    
                    var buffer = ""
                    var toolCalls: [[String: Any]] = []
                    var isToolUse = false
                    
                    for try await byte in asyncBytes {
                        if let character = String(bytes: [byte], encoding: .utf8) {
                            buffer += character
                            if character == "\n" {
    //                            print("Received data: \(buffer)")
                                
                                if buffer.hasPrefix("data: ") {
                                    let jsonString = buffer.dropFirst(6)
    //                                print("JSON string: \(jsonString)")
                                    
                                    do {
                                        if let jsonData = jsonString.data(using: .utf8),
                                           let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                            #if DEBUG
                                            //print("Parsed JSON object: \(jsonObject)")
                                            #endif
                                            
                                            if let type = jsonObject["type"] as? String {
                                                switch type {
                                                case "message_start":
                                                    if let message = jsonObject["message"] as? [String: Any],
                                                       let usage = message["usage"] as? [String: Any],
                                                       let inputTokenCount = usage["input_tokens"] as? Int {
                                                        inputTokens = inputTokenCount
                                                        continuation.yield(.inputTokens(inputTokens))
                                                    }
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
                                                case "message_delta":
                                                    if let usage = jsonObject["usage"] as? [String: Any],
                                                       let outputTokenCount = usage["output_tokens"] as? Int {
                                                        outputTokens = outputTokenCount
                                                        continuation.yield(.outputTokens(outputTokens))
                                                    }
                                                case "content_block_stop":
                                                    if isToolUse {
                                                        isToolUse = false
                                                    }
                                                case "message_stop":
                                                    if !toolCalls.isEmpty {
                                                        let calls: [ChatToolCall] = toolCalls.map {
                                                            ChatToolCall(toolCallId: $0["id"] as? String ?? "",
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
                                    } catch {
                                        print("Error parsing JSON: \(error.localizedDescription)")
                                        print("JSON string: \(jsonString)")  // Print JSON string in case of error
                                        throw error  // Re-throw the error to be caught by the outer catch
                                    }
                                }
                                buffer = ""
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    // If there's an error with the continuation, you can handle logging here as well
                    continuation.finish(throwing: error)
                }
            }
        }
    }


    static func nonStreamingResponse(from conversations: [Thread], config: ChatConfig) async throws -> NonStreamResponse {
        let request = try await createRequest(from: conversations, config: config)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        #if DEBUG
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
            print("Received JSON:")
            print(prettyPrintedString)
        }
        #endif
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw RuntimeError("Unexpected response type: \(response)")
        }

        guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let contentArray = jsonObject["content"] as? [[String: Any]],
              let usage = jsonObject["usage"] as? [String: Int] else {
            throw RuntimeError("Failed to parse JSON response")
        }
        
        let toolCalls = contentArray.filter { $0["type"] as? String == "tool_use" }
        let calls: [ChatToolCall] = toolCalls.compactMap { toolCall in
            guard let id = toolCall["id"] as? String,
                  let name = toolCall["name"] as? String,
                  let tool = ChatTool(rawValue: name),
                  let input = toolCall["input"] as? [String: Any],
                  let inputJson = try? JSONSerialization.data(withJSONObject: input),
                  let inputString = String(data: inputJson, encoding: .utf8) else {
                return nil
            }
            return ChatToolCall(toolCallId: id, tool: tool, arguments: inputString)
        }
        
        let text = contentArray.compactMap { $0["text"] as? String }.joined(separator: " ")
        
        let inputTokens = usage["input_tokens"] ?? 0
        let outputTokens = usage["output_tokens"] ?? 0
        
        return NonStreamResponse(
            content: text.isEmpty ? nil : text,
            toolCalls: calls.isEmpty ? nil : calls,
            inputTokens: inputTokens,
            outputTokens: outputTokens
        )
    }

    static func createRequest(from conversations: [Thread], config: ChatConfig) async throws -> URLRequest {
        let modelID = config.model.code
        let projectID = config.provider.host
        let location = "us-east5"
        let apiUrl = "https://\(location)-aiplatform.googleapis.com/v1/projects/\(projectID)/locations/\(location)/publishers/anthropic/models/\(modelID):streamRawPredict"
        
        guard let url = URL(string: apiUrl) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = try await GoogleAuth.shared.getValidAccessToken()
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
        
        if !config.systemPrompt.isEmpty {
            body["system"] = config.systemPrompt
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        return request
    }
    
    static func testModel(provider: Provider, model: AIModel) async -> Bool {
        let testThread = Thread(role: .user, content: String.testPrompt)
        let location = "us-east5"  // Assuming this is the default location
        let apiUrl = "https://\(location)-aiplatform.googleapis.com/v1/projects/\(provider.host)/locations/\(location)/publishers/anthropic/models/\(model.code):streamRawPredict"
        
        guard let url = URL(string: apiUrl) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let token = try await GoogleAuth.shared.getValidAccessToken()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let message = convert(conversation: testThread)
            
            let body: [String: Any] = [
                "anthropic_version": "vertex-2023-10-16",
                "messages": [message],
                "max_tokens": 100,  // A small number for testing
                "temperature": 1.0,
                "stream": false
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return false
            }
            
            guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let contentArray = jsonObject["content"] as? [[String: Any]] else {
                return false
            }
            
            let hasContent = contentArray.contains { content in
                if let text = content["text"] as? String, !text.isEmpty {
                    return true
                }
                return false
            }
            
            return hasContent
            
        } catch {
            print("Error testing Vertex AI model: \(error)")
            return false
        }
    }
}
