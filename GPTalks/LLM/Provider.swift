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
    
    var name: String
    var host: String
    @Attribute(.allowsCloudEncryption)
    var apiKey: String
    
    var type: ProviderType
    
    var color: String = "#000000"
    
    @Relationship(deleteRule: .cascade)
    var chatModel: Model
    
    @Relationship(deleteRule: .cascade)
    var models =  [Model]()
    
    init(name: String, host: String, apiKey: String, type: ProviderType = .openai) {
        self.name = name
        self.host = host
        self.apiKey = apiKey
        self.chatModel = Model(code: "gpt-3.5-turbo", name: "GPT-3.5 Turbo")
        self.type = type
    }

    func addOpenAIModels() {
        for model in Model.getOpenaiModels() {
            if !models.contains(where: { $0.code == model.code }) {
                models.append(model)
            }
        }
    }
    
    func addClaudeModels() {
        for model in Model.getClaudeModels() {
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
    
    static func getDemoProvider() -> Provider {
        let provider = Provider(name: "OpenAI", host: "api.openai.com", apiKey: "")
        provider.addOpenAIModels()
        provider.chatModel = provider.models.first!
        
        return provider
    }
}
