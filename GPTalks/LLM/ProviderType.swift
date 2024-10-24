//
//  ProviderType.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum ProviderType: String, Codable, CaseIterable, Identifiable {
    case openai
    case openrouter
    case groq
    case xai
    case mistral
    case perplexity
    case togetherai
    case anthropic
    case google
    case vertex
    case ollama
    case lmstudio
    case custom

    var id: ProviderType { self }

    var scheme: HTTPScheme {
        switch self {
        case .ollama, .lmstudio: .http
        default: .https
        }
    }
    
    var name: String {
        switch self {
        case .openai: "OpenAI"
        case .openrouter: "OpenRouter"
        case .groq: "Groq"
        case .xai: "xAI"
        case .mistral: "MistralAI"
        case .perplexity: "PerplexityAI"
        case .togetherai: "TogetherAI"
        case .anthropic: "Anthropic"
        case .google: "Google"
        case .vertex: "VertexAI"
        case .ollama: "Ollama"
        case .lmstudio: "LMStudio"
        case .custom: "Custom OpenAI"
        }
    }
    
    var imageName: String {
        switch self {
        case .openai: "brain.SFSymbol"
        case .anthropic: "anthropic.SFSymbol"
        case .google: "google.SFSymbol"
        case .vertex: "storm.SFSymbol"
        case .ollama: "ollama.SFSymbol"
        default: "brain.SFSymbol"
        }
    }
    
    var defaultHost: String {
        switch self {
        case .openai: "api.openai.com"
        case .anthropic: "api.anthropic.com"
        case .google: "generativelanguage.googleapis.com"
        case .vertex: ""
        case .ollama: "ollamahost:11434"
        case .perplexity: "api.perplexity.ai"
        case .groq: "api.groq.com/openai"
        case .xai: "api.x.ai"
        case .openrouter: "openrouter.ai/api"
        case .mistral: "api.mistral.ai"
        case .togetherai: "api.together.xyz"
        case .lmstudio: "localhost:1234"
        case .custom: ""
        }
    }
    
    var defaultColor: String {
        switch self {
        case .openai: "#00947A"
        case .anthropic: "#E6784B"
        case .google: "#E64335"
        case .vertex: "#4B62CA"
        case .ollama: "#EFEFEF"
        default: Color.randomColors.randomElement() ?? "#00947A"
        }
    }
    
    var supportedFileTypes: [UTType] {
        switch self {
        case .google: [.audio, .image, .pdf, .commaSeparatedText, .text]
        default: [.image, .pdf, .audio]
        }
    }
    
    func getDefaultModels() -> [ChatModel] {
        switch self {
        case .openai: ChatModel.getOpenaiModels()
        case .anthropic: ChatModel.getAnthropicModels()
        case .google: ChatModel.getGoogleModels()
        case .vertex: ChatModel.getVertexModels()
        case .ollama: ChatModel.getLocalModels()
        default: ChatModel.getOpenaiModels()
        }
    }
    
    func getService() -> any AIService.Type {
        switch self {
        case .openai, .ollama, .openrouter, .groq, .xai, .mistral, .perplexity, .togetherai, .lmstudio, .custom:
            OpenAIService.self
        case .anthropic:
            ClaudeService.self
        case .google:
            GoogleService.self
        case .vertex:
            VertexService.self
        }
    }
}
