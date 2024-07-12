//
//  Provider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData

@Model
class Provider {
    var id: UUID = UUID()
    var date: Date = Date()
    var order: Int = 0
    
    var name: String = ""
    var host: String = ""
    @Attribute(.allowsCloudEncryption)
    var apiKey: String = ""
    
    var type: ProviderType
    
    var color: String = "#00947A"
    
    @Relationship(deleteRule: .cascade)
    var chatModel: Model
    @Relationship(deleteRule: .cascade)
    var quickChatModel: Model
    
    @Relationship(deleteRule: .cascade)
    var models =  [Model]()
    
    init() {
        self.chatModel = Model.getDemoModel()
        self.quickChatModel = Model.getDemoModel()
        self.type = .openai
    }
    
    static func factory(type: ProviderType) -> Provider {
        let provider = Provider()
        provider.type = type
        provider.name = type.name
        provider.host = type.defaultHost
        provider.models = type.getDefaultModels()
        provider.chatModel = provider.models.first!
        provider.quickChatModel = provider.models.first!
        provider.color = type.defaultColor
        
        return provider
    }

    func addOpenAIModels() {
        for model in Model.getOpenaiModels() {
            if !models.contains(where: { $0.code == model.code }) {
                models.append(model)
            }
        }
    }
    
    func addClaudeModels() {
        for model in Model.getAnthropicModels() {
            if !models.contains(where: { $0.code == model.code }) {
                models.append(model)
            }
        }
    }
    
    func addGoogleModels() {
        for model in Model.getGoogleModels() {
            if !models.contains(where: { $0.code == model.code }) {
                models.append(model)
            }
        }
    }
}
