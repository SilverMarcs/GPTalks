//
//  Model.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData

@Model
final class AIModel: Hashable, Identifiable {
    var id: UUID = UUID()
    var order: Int = 0
    // TODO: rename to just type
    var modelType: ModelType = ModelType.chat

    var code: String
    var name: String
    var isEnabled: Bool = true
    
    var provider: Provider?

    init() {
        self.code = "Dummy"
        self.name = "Dummy"
    }

    init(code: String, name: String, provider: Provider? = nil, modelType: ModelType = .chat, order: Int = .max, isEnabled: Bool = true) {
        self.code = code
        self.name = name
        self.provider = provider
        self.modelType = modelType
        self.order = order
        self.isEnabled = isEnabled
    }
    
    func removeSelf() {
        provider?.models.removeAll(where: { $0.id == id })
    }
}


enum ModelType: String, CaseIterable, Codable {
    case chat
    case image
}

extension AIModel {
    static func getDemoModel() -> AIModel {
        return AIModel(code: "gpt-3.5-turbo", name: "GPT-3.5T")
    }
    
    static func getDemoImageModel() -> AIModel {
        return AIModel(code: "dall-e-3", name: "DALL-E-3", modelType: .image)
    }
    
    static func getOpenaiModels() -> [AIModel] {
        return [
            AIModel(code: "dall-e-2", name: "DALL-E-2", modelType: .image, order: 0),
            AIModel(code: "dall-e-3", name: "DALL-E-3", modelType: .image, order: 1),
            
            AIModel(code: "gpt-4o", name: "GPT-4o", order: 2),
            AIModel(code: "gpt-4o-mini", name: "GPT-4om", order: 3),
            AIModel(code: "gpt-4-turbo", name: "GPT-4T", order: 4),
            AIModel(code: "gpt-4-turbo-preview", name: "GPT-4TP", order: 5),
            AIModel(code: "gpt-4", name: "GPT-4", order: 6),
            AIModel(code: "gpt-3.5-turbo", name: "GPT-3.5T", order: 7),
        ]
    }
    
    static func getAnthropicModels() -> [AIModel] {
        return [
            AIModel(code: "claude-3-opus-20240229", name: "Claude-3O", order: 3),
            AIModel(code: "claude-3-sonnet-20240229", name: "Claude-3S", order: 2),
            AIModel(code: "claude-3-haiku-20240307", name: "Claude-3H", order: 1),
            AIModel(code: "claude-3-5-sonnet-20240620", name: "Claude-3.5S", order: 0),
        ]
    }
    
    static func getGoogleModels() -> [AIModel] {
        return [
            AIModel(code: "gemini-1.5-pro", name: "Gemini-1.5P", order: 0),
            AIModel(code: "gemini-1.5-flash", name: "Gemini-1.5F", order: 1),
            AIModel(code: "gemini-1.0-pro", name: "Gemini-1.0P", order: 2),
        ]
    }
    
    static func getLocalModels() -> [AIModel] {
        return [
            AIModel(code: "dummy-model", name: "Dummy", order: 0),
        ]
    }
}
