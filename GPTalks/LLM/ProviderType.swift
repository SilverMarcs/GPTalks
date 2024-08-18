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
    case local
    
    var id: ProviderType { self }
    
    static var allTypes: [ProviderType] {
        #if os(macOS)
        return [.openai, .anthropic, .google, .local]
        #else
        return [.openai, .anthropic, .google]
        #endif
    }
    
    var scheme: String {
        switch self {
        case .openai, .anthropic, .google: "https"
        case .local: "http"
        }
    }
    
    var name: String {
        switch self {
        case .openai: "OpenAI"
        case .anthropic: "Anthropic"
        case .google: "Google"
        case .local: "Local AI"
        }
    }
    
    var imageName: String {
        switch self {
        case .openai: "brain.SFSymbol"
        case .anthropic: "anthropic.SFSymbol"
        case .google: "google.SFSymbol"
        case .local: "ollama.SFSymbol"
        }
    }
    
    var defaultHost: String {
        switch self {
        case .openai: "api.openai.com"
        case .anthropic: "api.anthropic.com"
        case .google: "generativelanguage.googleapis.com"
        case .local: "localhost:11434"
        }
    }
    
    var defaultColor: String {
        switch self {
        case .openai: "#00947A"
        case .anthropic: "#E6784B"
        case .google: "#E64335"
        case .local: "#EFEFEF"
        }
    }
    
    var supportedFileTypes: [UTType] {
        switch self {
        case .openai: return [.image]
        case .anthropic: return [.image]
        case .google: return [.pdf, .text, .commaSeparatedText, .image, .audio]
        case .local: return []
        }
    }
    
    func getDefaultModels() -> [AIModel] {
        switch self {
        case .openai: return AIModel.getOpenaiModels()
        case .anthropic: return AIModel.getAnthropicModels()
        case .google: return AIModel.getGoogleModels()
        case .local: return AIModel.getLocalModels()
        }
    }
}
