//
//  ChatModel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation

struct ChatModel: Hashable, Identifiable, Codable {
    var id: UUID = UUID()
    var code: String
    var name: String

    init(code: String, name: String) {
        self.code = code
        self.name = name
    }
}


enum ModelType: String, CaseIterable, Codable, Hashable {
    case chat
    case image
}

extension ChatModel {
    static func getOpenaiModels() -> [ChatModel] {
        return [
            ChatModel(code: "gpt-4o", name: "GPT-4o"),
            ChatModel(code: "gpt-4o-mini", name: "GPT-4om"),
        ]
    }
    
    static func getAnthropicModels() -> [ChatModel] {
        return [
            ChatModel(code: "claude-3-opus-20240229", name: "Claude-3O"),
            ChatModel(code: "claude-3-sonnet-20240229", name: "Claude-3S"),
            ChatModel(code: "claude-3-haiku-20240307", name: "Claude-3H"),
            ChatModel(code: "claude-3-5-sonnet-20240620", name: "Claude-3.5S"),
        ]
    }
    
    static func getGoogleModels() -> [ChatModel] {
        return [
            ChatModel(code: "gemini-1.5-pro", name: "Gemini-1.5P"),
            ChatModel(code: "gemini-1.5-flash", name: "Gemini-1.5F"),
        ]
    }
    
    static func getVertexModels() -> [ChatModel] {
        return [
            ChatModel(code: "claude-3-haiku@20240307", name: "Claude-3H"),
            ChatModel(code: "claude-3-5-sonnet@20240620", name: "Claude-3.5S"),
        ]
    }
    
    static func getLocalModels() -> [ChatModel] {
        return [
            ChatModel(code: "dummy-model", name: "Dummy"),
        ]
    }
}
