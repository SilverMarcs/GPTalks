//
//  Model.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData

@Model
final class Model {
    var id: UUID = UUID()

    var code: String
    var name: String
    
    var provider: Provider?

    init() {
        self.code = ""
        self.name = ""
    }

    init(code: String, name: String, provider: Provider? = nil) {
        self.code = code
        self.name = name
        self.provider = provider
    }
    
    func removeSelf() {
        provider?.models.removeAll(where: { $0.id == id })
    }

    static func getDemoModel() -> Model {
        return Model(code: "gpt-3.5-turbo", name: "GPT-3.5T")
    }

    static func getOpenaiModels() -> [Model] {
        return [
            Model(code: "gpt-3.5-turbo", name: "GPT-3.5T"),
            Model(code: "gpt-4-turbo", name: "GPT-4T"),
            Model(code: "gpt-4-turbo-preview", name: "GPT-4TP"),
            Model(code: "gpt-4o", name: "GPT-4O"),
        ]
    }
    
    static func getClaudeModels() -> [Model] {
        return [
            Model(code: "claude-3.5-sonnet", name: "Claude-3.5S"),
        ]
    }
}
