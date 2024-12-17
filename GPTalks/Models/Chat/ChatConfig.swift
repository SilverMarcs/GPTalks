//
//  ChatConfig.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import Foundation
import SwiftData

@Model
final class ChatConfig: Equatable, Identifiable, Hashable {
    var temperature: Double? = ChatConfigDefaults.shared.temperature
    var frequencyPenalty: Double? = ChatConfigDefaults.shared.frequencyPenalty
    var presencePenalty: Double? = ChatConfigDefaults.shared.presencePenalty
    var topP: Double? = ChatConfigDefaults.shared.topP
    var maxTokens: Int? = ChatConfigDefaults.shared.maxTokens
    var stream: Bool = ChatConfigDefaults.shared.stream
    var useCache: Bool = ChatConfigDefaults.shared.useCache
    var systemPrompt: String
    var purpose: ChatConfigPurpose = ChatConfigPurpose.chat
    
    @Relationship(deleteRule: .nullify)
    var provider: Provider
    @Relationship(deleteRule: .nullify)
    var model: AIModel
    
    var tools: ChatConfigTools
    
    private init(provider: Provider, model: AIModel, temperature: Double?, frequencyPenalty: Double?, presencePenalty: Double?, topP: Double?, maxTokens: Int?, stream: Bool, systemPrompt: String, purpose: ChatConfigPurpose = .chat, tools: ChatConfigTools) {
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
    
    init(provider: Provider, purpose: ChatConfigPurpose) {
        self.provider = provider
        
        switch purpose {
            case .chat:
                self.systemPrompt = ChatConfigDefaults.shared.systemPrompt
                self.model = provider.chatModel
                self.tools = ChatConfigTools()
            case .title:
                self.systemPrompt = "Generate a title based on the content"
                self.model = provider.liteModel
                self.stream = false
                self.tools = ChatConfigTools(isTitle: true)
            case .quick:
                self.systemPrompt = AppConfig.shared.quickSystemPrompt
                self.model = provider.liteModel
                self.tools = ChatConfigTools()
        }
    }

    func copy(purpose: ChatConfigPurpose) -> ChatConfig {
        return ChatConfig(provider: self.provider, model: self.model, temperature: self.temperature, frequencyPenalty: self.frequencyPenalty, presencePenalty: self.presencePenalty, topP: self.topP, maxTokens: self.maxTokens, stream: self.stream, systemPrompt: self.systemPrompt, purpose: purpose, tools: self.tools)
    }
}

enum ChatConfigPurpose: Codable {
    case chat
    case title
    case quick
    
    var title: String {
        switch self {
            case .chat: return "(Forked)"
            case .title: return "Title"
            case .quick: return "Quick Chat"
        }
    }
}
