//
//  SessionConfig.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import Foundation
import SwiftData

@Model
final class SessionConfig: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SessionConfig(provider: provider, model: model, temperature: temperature, systemPrompt: systemPrompt)
        return copy
    }
    
    var temperature: Double = AppConfig.shared.temperature
    var systemPrompt: String = AppConfig.shared.systemPrompt
    
    @Relationship(deleteRule: .nullify)
    var provider: Provider
    @Relationship(deleteRule: .nullify)
    var model: Model
    
    init(provider: Provider, model: Model) {
        self.provider = provider
        self.model = model
    }
    
    init(provider: Provider = Provider.factory(type: .openai), isQuick: Bool = false) {
        self.provider = provider
        if isQuick {
            self.model = provider.quickChatModel
        } else {
            self.model = provider.chatModel
        }
    }
    
    init(provider: Provider, model: Model, temperature: Double, systemPrompt: String) {
        self.provider = provider
        self.model = model
        self.temperature = temperature
        self.systemPrompt = systemPrompt
    }
}
