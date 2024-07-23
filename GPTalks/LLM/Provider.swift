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
    
    @Relationship(deleteRule: .nullify)
    var chatModel: AIModel
    @Relationship(deleteRule: .nullify)
    var quickChatModel: AIModel
    @Relationship(deleteRule: .nullify)
    var titleModel: AIModel
    @Relationship(deleteRule: .nullify)
    var imageModel: AIModel
    
    @Relationship(deleteRule: .nullify)
    var models =  [AIModel]()
    
    var sortedModels: [AIModel] {
        models.sorted(by: { $0.order < $1.order })
    }
    
    var chatModels: [AIModel] {
        return models.filter { !$0.supportsImage}
    }
    
    var imageModels: [AIModel] {
        return models.filter { $0.supportsImage}
    }
    
    private init() {
        // never use this initializer
        self.chatModel = AIModel.getDemoModel()
        self.quickChatModel = AIModel.getDemoModel()
        self.titleModel = AIModel.getDemoModel()
        self.imageModel = AIModel.getDemoImageModel()
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
        for model in AIModel.getOpenaiModels() {
            if !models.contains(where: { $0.code == model.code }) {
                models.append(model)
            }
        }
    }
    
    func addClaudeModels() {
        for model in AIModel.getAnthropicModels() {
            if !models.contains(where: { $0.code == model.code }) {
                models.append(model)
            }
        }
    }
    
    func addGoogleModels() {
        for model in AIModel.getGoogleModels() {
            if !models.contains(where: { $0.code == model.code }) {
                models.append(model)
            }
        }
    }
}
