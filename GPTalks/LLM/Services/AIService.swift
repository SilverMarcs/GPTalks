//
//  AIService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import SwiftUI

protocol AIService {
    static func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<String, Error>
    static func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> String
    static func testModel(provider: Provider, model: AIModel) async -> Bool
}
