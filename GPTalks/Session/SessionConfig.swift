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
    func copy() -> SessionConfig {
        let copy = SessionConfig(provider: provider, model: model, temperature: temperature, systemPrompt: systemPrompt)
        return copy
    }
    
    var temperature: Double? = SessionConfigDefaults.shared.temperature
    var frequencyPenalty: Double? = SessionConfigDefaults.shared.frequencyPenalty
    var presencePenalty: Double? = SessionConfigDefaults.shared.presencePenalty
    var topP: Double? = SessionConfigDefaults.shared.topP
    var maxTokens: Int? = SessionConfigDefaults.shared.maxTokens
    var systemPrompt: String
    
    @Relationship(deleteRule: .nullify)
    var provider: Provider
    @Relationship(deleteRule: .nullify)
    var model: AIModel
    
    init(provider: Provider, model: AIModel) {
        self.provider = provider
        self.model = model
        self.systemPrompt = SessionConfigDefaults.shared.systemPrompt
    }
    
    init(provider: Provider = Provider.factory(type: .openai), isQuick: Bool = false) {
        self.provider = provider
        if isQuick {
            self.model = provider.quickChatModel
            self.systemPrompt = AppConfig.shared.quickSystemPrompt
        } else {
            self.model = provider.chatModel
            self.systemPrompt = SessionConfigDefaults.shared.systemPrompt
        }
    }
    
    init(provider: Provider, model: AIModel, temperature: Double?, systemPrompt: String) {
        self.provider = provider
        self.model = model
        self.temperature = temperature
        self.systemPrompt = systemPrompt
    }
}
