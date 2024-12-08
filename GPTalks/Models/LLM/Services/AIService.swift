//
//  AIService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import SwiftUI

protocol AIService {
    associatedtype ConvertedType
    
    static func streamResponse(from conversations: [Message], config: ChatConfig) -> AsyncThrowingStream<StreamResponse, Error>
    static func nonStreamingResponse(from conversations: [Message], config: ChatConfig) async throws -> NonStreamResponse
    static func testModel(provider: Provider, model: AIModel) async -> Bool
    static func convert(conversation: Message) throws -> ConvertedType
    static func refreshModels(provider: Provider) async -> [GenericModel]
}
