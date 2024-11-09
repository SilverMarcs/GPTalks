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
    case github
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
        case .github: "Github"
        case .anthropic: "Anthropic"
        case .google: "Google"
        case .vertex: "Vertex"
        case .ollama: "Ollama"
        case .lmstudio: "LMStudio"
        case .custom: "Custom OpenAI"
        }
    }
    
    var imageName: String {
        switch self {
        case .openai: "openai.SFSymbol"
        case .anthropic: "anthropic.SFSymbol"
        case .google: "google.SFSymbol"
        case .vertex: "storm.SFSymbol"
        case .mistral: "mistral.SFSymbol"
        case .perplexity: "perplexity.SFSymbol"
        case .xai: "xai.SFSymbol"
        case .groq: "groq.SFSymbol"
        case .github: "github.SFSymbol"
        case .ollama: "ollama.SFSymbol"
        case .custom: "openai.SFSymbol"
        default: "brain.SFSymbol"
        }
    }
    
    var defaultColor: String {
        switch self {
        case .openai: "#00947A"
        case .anthropic: "#E6784B"
        case .google: "#E64335"
        case .vertex: "#4B62CA"
        case .mistral: "#EB5A29"
        case .perplexity: "#2F7999"
        case .xai: "#111111"
        case .groq: "#F55036"
        case .github: "#181717"
        case .ollama: "#EFEFEF"
        default: Color.randomColors.randomElement() ?? "#00947A"
        }
    }
    
    var defaultHost: String {
        switch self {
        case .openai: "api.openai.com"
        case .anthropic: "api.anthropic.com"
        case .google: "generativelanguage.googleapis.com"
        case .vertex: ""
        case .ollama: "ollamahost:11434"
        case .github: "models.inference.ai.azure.com"
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
    
    var supportedFileTypes: [UTType] {
        switch self {
        case .google: [.audio, .image, .pdf, .commaSeparatedText, .text, .sourceCode]
        default: [.image, .pdf, .audio, .sourceCode]
        }
    }
    
    func getDefaultModels() -> [AIModel] {
        switch self {
        case .openai: AIModel.getOpenaiModels()
        case .anthropic: AIModel.getAnthropicModels()
        case .google: AIModel.getGoogleModels()
        case .vertex: AIModel.getVertexModels()
        case .xai: AIModel.getXaiModels()
        case .openrouter: AIModel.getOpenrouterModels()
        case .github: AIModel.getOpenaiModels()
        case .groq: AIModel.getGroqModels()
        case .mistral: AIModel.getMistralModels()
        case .perplexity: AIModel.getPerplexityModels()
        case .togetherai: AIModel.getTogetherModels()
        case .lmstudio: AIModel.getLocalModels()
        case .ollama: AIModel.getLocalModels()
        case .custom: AIModel.getOpenaiModels()
        }
    }
    
    func getService() -> any AIService.Type {
        switch self {
        case .anthropic:
            ClaudeService.self
        case .google:
            GoogleService.self
        case .vertex:
            VertexService.self
        default:
            OpenAIService.self
        }
    }
}
