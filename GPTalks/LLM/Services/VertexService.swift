//
//  VertexService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/09/2024.
//

import Foundation

import Foundation

struct VertexService: AIService {
    static func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<String, any Error> {
        return AsyncThrowingStream { continuation in
            do {
                let request = try createRequest(from: conversations, config: config)
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    guard let data = data else {
                        continuation.finish(throwing: URLError(.badServerResponse))
                        return
                    }
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        let lines = responseString.split(separator: "\n")
                        for line in lines {
                            if line.hasPrefix("data: ") {
                                let jsonString = line.dropFirst(6)
                                
                                if let jsonData = jsonString.data(using: .utf8) {
                                    do {
                                        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                                           let type = jsonObject["type"] as? String,
                                           type == "content_block_delta",
                                           let delta = jsonObject["delta"] as? [String: Any],
                                           let text = delta["text"] as? String {
                                            continuation.yield(text)
                                        }
                                    } catch {
                                        continuation.finish(throwing: error)
                                        return
                                    }
                                }
                            }
                        }
                    } else {
                        continuation.finish(throwing: URLError(.cannotParseResponse))
                        return
                    }
                    
                    continuation.finish()
                }
                
                task.resume()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }

    static func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> String {
        let request = try createRequest(from: conversations, config: config)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let contentArray = jsonObject["content"] as? [[String: Any]] else {
            throw URLError(.cannotParseResponse)
        }
        
        let text = contentArray.compactMap { $0["text"] as? String }.joined(separator: " ")
        return text
    }

    private static func createRequest(from conversations: [Conversation], config: SessionConfig) throws -> URLRequest {
        let modelID = config.model.code
        let location = "us-east5"
        let projectID = config.provider.host
        let apiUrl = "https://\(location)-aiplatform.googleapis.com/v1/projects/\(projectID)/locations/\(location)/publishers/anthropic/models/\(modelID):streamRawPredict"
        
        guard let url = URL(string: apiUrl) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.provider.apiKey)", forHTTPHeaderField: "Authorization")
        
        let messages: [[String: Any]] = conversations.map { conversation in
            return [
                "role": conversation.role.rawValue,
                "content": conversation.content
            ]
        }
        
        let body: [String: Any] = [
            "anthropic_version": "vertex-2023-10-16",
            "messages": messages,
            "max_tokens": config.maxTokens,
            "temperature": config.temperature,
            "stream": config.stream
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        return request
    }
    
    static func testModel(provider: Provider, model: AIModel) async -> Bool {
        return false
    }
}
