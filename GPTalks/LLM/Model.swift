//
//  Model.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData

@Model
final class Model: Hashable, NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Model(code: code, name: name)
        copy.provider = provider
        copy.order = order
        
        return copy
    }
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

extension Model {
    static func getDemoModel() -> Model {
        return Model(code: "gpt-3.5-turbo", name: "GPT-3.5T")
    }
    
    static func getDemoImageModel() -> Model {
        return Model(code: "dall-e-3", name: "DALL-E-3", supportsImage: true)
    }
    
    static func getOpenaiModels() -> [Model] {
        return [
            Model(code: "gpt-3.5-turbo", name: "GPT-3.5T"),
            Model(code: "gpt-4", name: "GPT-4"),
            Model(code: "gpt-4-turbo", name: "GPT-4T"),
            Model(code: "gpt-4-turbo-preview", name: "GPT-4TP"),
            Model(code: "gpt-4o", name: "GPT-4O"),
            Model(code: "gpt-4o-mini", name: "GPT-4Om"),
            
            Model(code: "dall-e-2", name: "DALL-E-2", supportsImage: true),
            Model(code: "dall-e-3", name: "DALL-E-3", supportsImage: true),
        ]
    }
    
    static func getAnthropicModels() -> [Model] {
        return [
            Model(code: "claude-3-opus-20240229", name: "Claude-3O"),
            Model(code: "claude-3-sonnet-20240229", name: "Claude-3S"),
            Model(code: "claude-3-haiku-20240307", name: "Claude-3H"),
            Model(code: "claude-3-5-sonnet-20240620", name: "Claude-3.5S"),
        ]
    }
    
    static func getGoogleModels() -> [Model] {
        return [
            Model(code: "gemini-1.5-pro", name: "Gemini-1.5P"),
            Model(code: "gemini-1.5-flash", name: "Gemini-1.5F"),
            Model(code: "gemini-1.0-pro", name: "Gemini-1.0P"),
        ]
    }
}
