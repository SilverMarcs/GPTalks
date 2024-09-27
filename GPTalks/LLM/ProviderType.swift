//
//  ProviderType.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import Foundation
import UniformTypeIdentifiers

enum ProviderType: String, Codable, CaseIterable, Identifiable {
    case openai
    case anthropic
    case google
    case vertex
    case local
    
    var id: ProviderType { self }
    
    static var allTypes: [ProviderType] {
        #if os(macOS)
        [.openai, .anthropic, .google, .vertex, .local]
        #else
        [.openai, .anthropic, .google, .vertex]
        #endif
    }
    
    var scheme: String {
        switch self {
        case .openai, .anthropic, .google, .vertex: "https"
        case .local: "http"
        }
    }
    
    var name: String {
        switch self {
        case .openai: "OpenAI"
        case .anthropic: "Anthropic"
        case .google: "Google"
        case .vertex: "Vertex"
        case .local: "Local OpenAI"
        }
    }
    
    var imageName: String {
        switch self {
        case .openai: "brain.SFSymbol"
        case .anthropic: "anthropic.SFSymbol"
        case .google: "google.SFSymbol"
        case .vertex: "storm.SFSymbol"
        case .local: "ollama.SFSymbol"
        }
    }
    
    var defaultHost: String {
        switch self {
        case .openai: "api.openai.com"
        case .anthropic: "api.anthropic.com"
        case .google: "generativelanguage.googleapis.com"
        case .vertex: ""
        case .local: "localhost:11434"
        }
    }
    
    var defaultColor: String {
        switch self {
        case .openai: "#00947A"
        case .anthropic: "#E6784B"
        case .google: "#E64335"
        case .vertex: "#4B62CA"
        case .local: "#EFEFEF"
        }
    }
    
    var supportedFileTypes: [UTType] {
        switch self {
        case .openai: [.image, .pdf, .commaSeparatedText, .text, .url]
        case .anthropic:  [.image, .pdf, .commaSeparatedText, .text, .url]
        case .google: [.audio, .image, .pdf, .commaSeparatedText, .text, .url]
        case .vertex: [.image, .pdf, .commaSeparatedText, .text, .url]
        case .local: [.pdf, .commaSeparatedText, .text, .url]
        }
    }
    
    func getDefaultModels() -> [AIModel] {
        switch self {
        case .openai: AIModel.getOpenaiModels()
        case .anthropic: AIModel.getAnthropicModels()
        case .google: AIModel.getGoogleModels()
        case .vertex: AIModel.getVertexModels()
        case .local: AIModel.getLocalModels()
        }
    }
    
    func getService() -> any AIService.Type {
        switch self {
        case .openai, .local:
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
