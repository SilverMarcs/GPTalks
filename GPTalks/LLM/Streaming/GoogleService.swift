//
//  GoogleService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import Foundation
import SwiftUI
import GoogleGenerativeAI

class GoogleService: AIService {
    func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<String, Error> {
        let (model, messages) = createModelAndMessages(from: conversations, config: config)
        return streamGoogleResponse(model: model, messages: messages)
    }
    
    func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> String {
        let (model, messages) = createModelAndMessages(from: conversations, config: config)
        return try await nonStreamingGoogleResponse(model: model, messages: messages)
    }
    
    private func createModelAndMessages(from conversations: [Conversation], config: SessionConfig) -> (GenerativeModel, [ModelContent]) {
        let systemPrompt = ModelContent(role: "system", parts: [.text(config.systemPrompt)])
        
        let genConfig = GenerationConfig(
            temperature: config.temperature.map { Float($0) },
            topP: config.topP.map { Float($0) },
            maxOutputTokens: config.maxTokens
        )
        
        let model = GenerativeModel(
            name: config.model.code,
            apiKey: config.provider.apiKey,
            generationConfig: genConfig,
            systemInstruction: systemPrompt)
        
        let messages = conversations.map { $0.toGoogle() }
        
        return (model, messages)
    }
    
    private func streamGoogleResponse(model: GenerativeModel, messages: [ModelContent]) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let responseStream = model.generateContentStream(messages)
                    
                    for try await response in responseStream {
                        if let content = response.text {
                            continuation.yield(content)
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func nonStreamingGoogleResponse(model: GenerativeModel, messages: [ModelContent]) async throws -> String {
        let response = try await model.generateContent(messages)
        return response.text ?? ""
    }
}
