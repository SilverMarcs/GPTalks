//
//  AIService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import SwiftUI

protocol AIService {
    associatedtype ConvertedType
    
    static func streamResponse(from conversations: [Conversation], config: SessionConfig) -> AsyncThrowingStream<StreamResponse, Error>
    static func nonStreamingResponse(from conversations: [Conversation], config: SessionConfig) async throws -> StreamResponse
    static func testModel(provider: Provider, model: AIModel) async -> Bool // TODO: separate model tester for images and audio
    static func convert(conversation: Conversation) -> ConvertedType
    static func refreshModels(provider: Provider) async -> [AIModel]
}
