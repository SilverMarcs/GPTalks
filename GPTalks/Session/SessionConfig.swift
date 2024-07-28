//
//  SessionConfig.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import Foundation
import SwiftData

@Model
final class SessionConfig {
    var temperature: Double? = SessionConfigDefaults.shared.temperature
    var frequencyPenalty: Double? = SessionConfigDefaults.shared.frequencyPenalty
    var presencePenalty: Double? = SessionConfigDefaults.shared.presencePenalty
    var topP: Double? = SessionConfigDefaults.shared.topP
    var maxTokens: Int? = SessionConfigDefaults.shared.maxTokens
    var systemPrompt: String
    var purpose: SessionConfigPurpose = SessionConfigPurpose.chat
    
    @Relationship(deleteRule: .nullify)
    var provider: Provider
    @Relationship(deleteRule: .nullify)
    var model: AIModel
    
    init(provider: Provider, model: AIModel, temperature: Double?, frequencyPenalty: Double?, presencePenalty: Double?, topP: Double?, maxTokens: Int?, systemPrompt: String, purpose: SessionConfigPurpose = .chat) {
        self.provider = provider
        self.model = model
        self.temperature = temperature
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
        self.topP = topP
        self.maxTokens = maxTokens
        self.systemPrompt = systemPrompt
        self.purpose = purpose
    }
    
    init(provider: Provider = Provider.factory(type: .openai),
         temperature: Double? = nil,
         frequencyPenalty: Double? = nil,
         presencePenalty: Double? = nil,
         topP: Double? = nil,
         maxTokens: Int? = nil,
         purpose: SessionConfigPurpose = .chat) {
        
        self.provider = provider
        self.temperature = temperature
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
        self.topP = topP
        self.maxTokens = maxTokens
        
        switch purpose {
            case .chat:
                self.systemPrompt = SessionConfigDefaults.shared.systemPrompt
                self.model = provider.chatModel
            case .title:
                self.systemPrompt = ""
                self.model = provider.titleModel
            case .quick:
                self.systemPrompt = AppConfig.shared.quickSystemPrompt
                self.model = provider.quickChatModel
        }
    }

    func copy(purpose: SessionConfigPurpose) -> SessionConfig {
        return SessionConfig(provider: self.provider, model: self.model, temperature: self.temperature, frequencyPenalty: self.frequencyPenalty, presencePenalty: self.presencePenalty, topP: self.topP, maxTokens: self.maxTokens, systemPrompt: self.systemPrompt, purpose: purpose)
    }
}

enum SessionConfigPurpose: Codable {
    case chat
    case title
    case quick
    
    var title: String {
        switch self {
            case .chat: return "Chat Session"
            case .title: return "Title"
            case .quick: return "Quick Session"
        }
    }
}
