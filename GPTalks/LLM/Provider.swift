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
    var isEnabled: Bool = true
    
    @Relationship(deleteRule: .cascade)
    var chatModel: Model
    @Relationship(deleteRule: .cascade)
    var quickChatModel: Model
    @Relationship(deleteRule: .cascade)
    var titleModel: Model
    @Relationship(deleteRule: .cascade)
    var imageModel: Model
    
    @Relationship(deleteRule: .cascade)
    var models =  [Model]()
    
    var chatModels: [Model] {
        return models.filter { !$0.supportsImage}
    }
    
    var imageModels: [Model] {
        return models.filter { $0.supportsImage}
    }
    
    private init() {
        // never use this initializer
        self.chatModel = Model.getDemoModel()
        self.quickChatModel = Model.getDemoModel()
        self.titleModel = Model.getDemoModel()
        self.imageModel = Model.getDemoImageModel()
        self.type = .openai
    }
    
    static func factory(type: ProviderType) -> Provider {
        let provider = Provider()
        provider.type = type
        provider.name = type.name
        provider.host = type.defaultHost
        provider.models = type.getDefaultModels()
        provider.color = type.defaultColor
        
        if let first = provider.chatModels.first {
            provider.chatModel = first
            provider.quickChatModel = first
            provider.titleModel = first
        }
        
        if let first = provider.imageModels.first {
            provider.imageModel = first
        }
        
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
