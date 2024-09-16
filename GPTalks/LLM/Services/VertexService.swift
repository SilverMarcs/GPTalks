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
        let processedContents = ContentHelper.processDataFiles(conversation.dataFiles, conversationContent: conversation.content)
        
        // Convert processed contents into dictionary format
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
                contentObjects.append([
                    "type": "text",
                    "text": text
                ])
            }
        }
        
        let finalContent: [String: Any] = [
            "role": conversation.role.rawValue,
            "content": contentObjects
        ]
        
        return finalContent
    }
    
    static func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<StreamResponse, any Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let request = try await createRequest(from: conversations, config: config)
                    
                    let (data, _) = try await URLSession.shared.data(for: request)
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        let lines = responseString.split(separator: "\n")
                        for line in lines {
                            if line.hasPrefix("data: ") {
                                let jsonString = line.dropFirst(6)
                                
                                if let jsonData = jsonString.data(using: .utf8) {
                                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                                       let type = jsonObject["type"] as? String,
                                       type == "content_block_delta",
                                       let delta = jsonObject["delta"] as? [String: Any],
                                       let text = delta["text"] as? String {
                                        continuation.yield(.content(text))
                                    }
                                }
                            }
                        }
                    } else {
                        throw URLError(.cannotParseResponse)
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
//        return text
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
        
        let body: [String: Any] = [
            "anthropic_version": "vertex-2023-10-16",
            "messages": messages,
            "max_tokens": config.maxTokens as Any,
            "temperature": config.temperature as Any,
            "stream": config.stream
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        return request
    }
    
    static func testModel(provider: Provider, model: AIModel) async -> Bool {
        return false
    }
}
