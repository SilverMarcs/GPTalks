//
//  AIModel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/11/2024.
//

import Foundation
import SwiftData

@Model
class AIModel: Hashable, Identifiable {
    var id: UUID = UUID()
    var code: String
    var name: String
    var testResult: Bool?
    var type: ModelType
    
    init(code: String, name: String, type: ModelType) {
        self.code = code
        self.name = name
        self.type = type
    }
}

extension AIModel {
    static func getOpenAITTSModels() -> [AIModel] {
        return [
            AIModel(code: "whisper-1", name: "Whisper-1", type: .stt),
        ]
    }
}

extension AIModel {
    static func getOpenImageModels() -> [AIModel] {
        return [
            AIModel(code: "dall-e-2", name: "DALL-E-2", type: .image),
            AIModel(code: "dall-e-3", name: "DALL-E-3", type: .image),
        ]
    }
}

extension AIModel {
    static func getOpenaiModels() -> [AIModel] {
        return [
            AIModel(code: "gpt-4o-mini", name: "GPT-4om", type: .chat),
            AIModel(code: "gpt-4o", name: "GPT-4o", type: .chat),
        ]
    }
    
    static func getAnthropicModels() -> [AIModel] {
        return [
            AIModel(code: "claude-3-5-haiku-latest", name: "Claude-3.5H", type: .chat),
            AIModel(code: "claude-3-5-sonnet-latest", name: "Claude-3.5S", type: .chat),
        ]
    }
    
    static func getGoogleModels() -> [AIModel] {
        return [
            AIModel(code: "gemini-1.5-flash-latest", name: "Gemini-1.5F", type: .chat),
            AIModel(code: "gemini-1.5-pro-latest", name: "Gemini-1.5P", type: .chat),

        ]
    }
    
    static func getVertexModels() -> [AIModel] {
        return [
            AIModel(code: "claude-3-5-haiku@20241022", name: "Claude-3.5H", type: .chat),
            AIModel(code: "claude-3-5-sonnet@20240620", name: "Claude-3.5S", type: .chat),
        ]
    }
    
    static func getLocalModels() -> [AIModel] {
        return [
            AIModel(code: "dummy-model", name: "Dummy", type: .chat),
        ]
    }
}
