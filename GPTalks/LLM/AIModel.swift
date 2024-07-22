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
    var supportsImage: Bool = false

    var code: String
    var name: String
    
    var provider: Provider?

    init() {
        self.code = ""
        self.name = ""
    }

    init(code: String, name: String, provider: Provider? = nil, supportsImage: Bool = false) {
        self.code = code
        self.name = name
        self.provider = provider
        self.supportsImage = supportsImage
    }
    
    func removeSelf() {
        provider?.models.removeAll(where: { $0.id == id })
    }
}

extension AIModel {
    static func getDemoModel() -> AIModel {
        return AIModel(code: "gpt-3.5-turbo", name: "GPT-3.5T")
    }
    
    static func getDemoImageModel() -> AIModel {
        return AIModel(code: "dall-e-3", name: "DALL-E-3", supportsImage: true)
    }
    
    static func getOpenaiModels() -> [AIModel] {
        return [
            AIModel(code: "gpt-3.5-turbo", name: "GPT-3.5T"),
            AIModel(code: "gpt-4", name: "GPT-4"),
            AIModel(code: "gpt-4-turbo", name: "GPT-4T"),
            AIModel(code: "gpt-4-turbo-preview", name: "GPT-4TP"),
            AIModel(code: "gpt-4o", name: "GPT-4O"),
            AIModel(code: "gpt-4o-mini", name: "GPT-4Om"),
            
            AIModel(code: "dall-e-2", name: "DALL-E-2", supportsImage: true),
            AIModel(code: "dall-e-3", name: "DALL-E-3", supportsImage: true),
        ]
    }
    
    static func getAnthropicModels() -> [AIModel] {
        return [
            AIModel(code: "claude-3-opus-20240229", name: "Claude-3O"),
            AIModel(code: "claude-3-sonnet-20240229", name: "Claude-3S"),
            AIModel(code: "claude-3-haiku-20240307", name: "Claude-3H"),
            AIModel(code: "claude-3-5-sonnet-20240620", name: "Claude-3.5S"),
        ]
    }
    
    static func getGoogleModels() -> [AIModel] {
        return [
            AIModel(code: "gemini-1.5-pro", name: "Gemini-1.5P"),
            AIModel(code: "gemini-1.5-flash", name: "Gemini-1.5F"),
            AIModel(code: "gemini-1.0-pro", name: "Gemini-1.0P"),
        ]
    }
}
