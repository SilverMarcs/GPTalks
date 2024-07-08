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
    
    var color: String = "#FFFFFF"
    
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
    
    static func getDemoProvider() -> Provider {
        let provider = Provider(name: "OpenAI", host: "api.openai.com", apiKey: "")
        provider.addOpenAIModels()
        provider.chatModel = provider.models.first!
        
        return provider
    }
}

enum ProviderType: Codable, CaseIterable, Identifiable {
    case openai
    case claude
    case google
    
    var id: ProviderType { self }
    
    var name: String {
        switch self {
        case .openai: "OpenAI"
        case .claude: "Claude"
        case .google: "Google"
        }
    }
}

import SwiftUI

//@Model
//class ColorComponents {
//    let red: Float = 1.0
//    let green: Float = 1.0
//    let blue: Float = 1.0
//    let opacity: Float = 1.0
//    
//    init() {}
//    
//    init(color: Color.Resolved) {
//        self.red = color.red
//        self.green = color.green
//        self.blue = color.blue
//        self.opacity = color.opacity
//    }
//    
//    var color: Color {
//        Color(red: Double(red), green: Double(green), blue: Double(blue))
//    }
//    
//    static func fromColor(_ color: Color) -> ColorComponents {
//        let resolved = color.resolve(in: EnvironmentValues())
//        return ColorComponents(color: resolved)
//    }
//}
