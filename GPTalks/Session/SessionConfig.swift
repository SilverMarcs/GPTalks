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
    var stream: Bool = SessionConfigDefaults.shared.stream
    var systemPrompt: String
    var purpose: SessionConfigPurpose = SessionConfigPurpose.chat
    
    @Relationship(deleteRule: .nullify)
    var provider: Provider
    @Relationship(deleteRule: .nullify)
    var model: ChatModel
    
    var tools: SessionConfigTools
    
    private init(provider: Provider, model: ChatModel, temperature: Double?, frequencyPenalty: Double?, presencePenalty: Double?, topP: Double?, maxTokens: Int?, stream: Bool, systemPrompt: String, purpose: SessionConfigPurpose = .chat, tools: SessionConfigTools) {
        self.provider = provider
        self.model = model
        self.temperature = temperature
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
        self.topP = topP
        self.maxTokens = maxTokens
        self.stream = stream
        self.systemPrompt = systemPrompt
        self.purpose = purpose
        self.tools = tools
    }
    
    init(provider: Provider, purpose: SessionConfigPurpose) {
        self.provider = provider
        
        switch purpose {
            case .chat:
                self.systemPrompt = SessionConfigDefaults.shared.systemPrompt
                self.model = provider.chatModel
                self.tools = SessionConfigTools()
            case .title:
                self.systemPrompt = ""
                self.model = provider.titleModel
                self.stream = false
                self.tools = SessionConfigTools(isTitle: true)
            case .quick:
                self.systemPrompt = AppConfig.shared.quickSystemPrompt
                self.model = provider.quickChatModel
                self.tools = SessionConfigTools()
        }
    }

    func copy(purpose: SessionConfigPurpose) -> SessionConfig {
        return SessionConfig(provider: self.provider, model: self.model, temperature: self.temperature, frequencyPenalty: self.frequencyPenalty, presencePenalty: self.presencePenalty, topP: self.topP, maxTokens: self.maxTokens, stream: self.stream, systemPrompt: self.systemPrompt, purpose: purpose, tools: self.tools)
    }
}

enum SessionConfigPurpose: Codable {
    case chat
    case title
    case quick
    
    var title: String {
        switch self {
            case .chat: return "(Forked)"
            case .title: return "Title"
            case .quick: return "Quick Session"
        }
    }
}
