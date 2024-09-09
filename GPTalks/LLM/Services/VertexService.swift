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
    
    static func convert(conversation: Conversation) -> [String: Any] {
        var contentObjects: [[String: Any]] = []
        
        for dataFile in conversation.dataFiles {
            if dataFile.fileType.conforms(to: .image) {
                let imageSource: [String: Any] = [
                    "type": "base64",
                    "media_type": dataFile.mimeType,
                    "data": dataFile.data.base64EncodedString()
                ]
                let imageContent: [String: Any] = [
                    "type": "image",
                    "source": imageSource
                ]
                contentObjects.append(imageContent)
            } else if dataFile.fileType.conforms(to: .pdf) {
                if let url = FileHelper.createTemporaryURL(for: dataFile) {
                    let contents = readPDF(from: url)
                    contentObjects.append([
                        "type": "text",
                        "text": "PDF File contents: \n\(contents)\n Respond to the user based on their query."
                    ])
                }
            } else if dataFile.fileType.conforms(to: .text) {
                if let textContent = String(data: dataFile.data, encoding: .utf8) {
                    contentObjects.append([
                        "type": "text",
                        "text": "Text File contents: \n\(textContent)\n Respond to the user based on their query."
                    ])
                }
            }
        }
        
        // Add the main conversation content
        contentObjects.append([
            "type": "text",
            "text": conversation.content
        ])
        
        // Construct the final dictionary
        let finalContent: [String: Any] = [
            "role": conversation.role.rawValue,
            "content": contentObjects
        ]
        
        return finalContent
    }
    
    static func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<String, any Error> {
        return AsyncThrowingStream { continuation in
            Task { @MainActor in
                do {
                    let request = try await createRequest(from: conversations, config: config)
                    
                    let (data, _) = try await URLSession.shared.data(for: request)
                    
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
                        throw URLError(.cannotParseResponse)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    static func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> String {
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
        return text
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
