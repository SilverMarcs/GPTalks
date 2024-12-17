//
//  BedrockService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/12/2024.
//

import Foundation
import AWSBedrock
import AWSBedrockRuntime
import AWSClientRuntime

struct BedrockService {
    static func getService() -> BedrockRuntimeClient {
        let region = "us-east-1"
        let runtimeConfig = try! BedrockRuntimeClient.BedrockRuntimeClientConfiguration(
            region: region
        )
        return BedrockRuntimeClient(config: runtimeConfig)
    }

    static func refreshModels() async throws -> [GenericModel] {
        let request = ListFoundationModelsInput()
        let bedrockClient = try await BedrockClient()
        let response = try await bedrockClient.listFoundationModels(input: request)
        
        guard let modelSummaries = response.modelSummaries else {
            return []
        }
        
        return modelSummaries.map { summary in
            let modelId = summary.modelId ?? ""
            let modelName = summary.modelName ?? modelId
            return GenericModel(code: modelId, name: modelName)
        }
    }

    static func streamResponse(messages: [Message], modelId: String = "anthropic.claude-v2") -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let request = try createStreamRequest(messages: messages, modelId: modelId)
                    let client = Self.getService()
                    let response = try await client.invokeModelWithResponseStream(input: request)
                    
                    guard let stream = response.body else {
                        continuation.finish()
                        return
                    }
                    
                    for try await chunk in stream {
                        if case .chunk(let payloadPart) = chunk,
                           let bytes = payloadPart.bytes,
                           let text = String(data: bytes, encoding: .utf8) {
                            continuation.yield(text)
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private static func createStreamRequest(messages: [Message], modelId: String) throws -> InvokeModelWithResponseStreamInput {
        let requestBody = ClaudeRequest(
            anthropic_version: "bedrock-2023-05-31",
            max_tokens: 4096,
            messages: messages.map { msg in
                ClaudeMessage(role: "ß", content: msg.content)
            }
        )
        
        let jsonData = try JSONEncoder().encode(requestBody)
        
        return InvokeModelWithResponseStreamInput(
            body: jsonData,
            contentType: "application/json",
            modelId: modelId
        )
    }
}

struct ClaudeRequest: Codable {
    let anthropic_version: String
    let max_tokens: Int
    let messages: [ClaudeMessage]
}

struct ClaudeMessage: Codable {
    let role: String
    let content: String
}

// Supporting types
struct ChatMessage {
    let role: String // "user" or "assistant"
    let content: String
}


// Usage example:
