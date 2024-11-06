//
//  AIService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import SwiftUI

protocol AIService {
    associatedtype ConvertedType
    
    static func streamResponse(from conversations: [Thread], config: ChatConfig) -> AsyncThrowingStream<StreamResponse, Error>
    static func nonStreamingResponse(from conversations: [Thread], config: ChatConfig) async throws -> NonStreamResponse
    static func testModel(provider: Provider, model: AIModel) async -> Bool // TODO: separate model tester for images and audio
    static func convert(conversation: Thread) throws -> ConvertedType
    static func refreshModels(provider: Provider) async -> [GenericModel]
}
