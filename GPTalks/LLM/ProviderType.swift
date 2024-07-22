//
//  ProviderType.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import Foundation

enum ProviderType: String, Codable, CaseIterable, Identifiable {
    case openai
    case anthropic
    case google
    
    var id: ProviderType { self }
    
    var name: String {
        switch self {
        case .openai: "OpenAI"
        case .anthropic: "Anthropic"
        case .google: "Google"
        }
    }
    
    var imageName: String {
        switch self {
        case .openai: "openai"
        case .anthropic: "anthropic"
        case .google: "google"
        }
    }
    
    var imageOffset: CGFloat {
        switch self {
        case .openai: 4
        case .anthropic: 6
        case .google: 12
        }
    }
    
    var defaultHost: String {
        switch self {
        case .openai: "api.openai.com"
        case .anthropic: "api.anthropic.com"
        case .google: "generativelanguage.googleapis.com"
        }
    }
    
    var defaultColor: String {
        switch self {
        case .openai: "#00947A"
        case .anthropic: "#E6784B"
        case .google: "#E64335"
        }
    }
    
    func getDefaultModels() -> [AIModel] {
        switch self {
        case .openai: return AIModel.getOpenaiModels()
        case .anthropic: return AIModel.getAnthropicModels()
        case .google: return AIModel.getGoogleModels()
        }
    }
}
