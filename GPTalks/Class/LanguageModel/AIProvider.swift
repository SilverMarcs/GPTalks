//
//  AIProvider.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI
import OpenAI

enum AIProvider: String, CaseIterable, Codable {
    case openai
    case openrouter
    case custom

    var id: String {
        switch self {
        case .openai:
            return "openai"
        case .openrouter:
            return "openrouter"
        case .custom:
            return "pawan"
        }
    }
    
    var config: OpenAI.Configuration {
        switch self {
        case .openai:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.OAIkey,
                host: "https://api.openai.com"
            )
        case .openrouter:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.ORkey,
                host: "https://openrouter.ai/api",
                additionalHeaders: ["HTTP-Referer" : "https://example.com"]
            )
        case .custom:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Ckey,
                host: "http://127.0.0.1:1337"
            )
        }
    }

    func service(openAIconfiguration: OpenAI.Configuration) -> OpenAI {
        return OpenAI(configuration: openAIconfiguration)
    }

    var iconName: String {
        return rawValue.lowercased()
    }
    
    var accentColor: Color {
        switch self {
        case .openai:
            return Color("greenColor")
        case .openrouter:
            return Color("purpleColor")
        case .custom:
            return Color("orangeColor")
        }
    }

    var name: String {
        switch self {
        case .openai:
            return "OpenAI"
        case .openrouter:
            return "OpenRouter"
        case .custom:
            return "PAI"
        }
    }

    var contextLength: Int {
        switch self {
        case .openai:
            return AppConfiguration.shared.OAIcontextLength
        case .openrouter:
            return AppConfiguration.shared.ORcontextLength
        case .custom:
            return AppConfiguration.shared.CcontextLength
        }
    }

    var temperature: Double {
        switch self {
        case .openai:
            return AppConfiguration.shared.OAItemperature
        case .openrouter:
            return AppConfiguration.shared.ORtemperature
        case .custom:
            return AppConfiguration.shared.Ctemperature
        }
    }

    var systemPrompt: String {
        switch self {
        case .openai:
            return AppConfiguration.shared.OAIsystemPrompt
        case .openrouter:
            return AppConfiguration.shared.ORsystemPrompt
        case .custom:
            return AppConfiguration.shared.CHost
        }
    }

    var preferredModel: Model {
        switch self {
        case .openai:
            return AppConfiguration.shared.OAImodel
        case .openrouter:
            return AppConfiguration.shared.ORmodel
        case .custom:
            return AppConfiguration.shared.Cmodel
        }
    }

    var models: [Model] {
        switch self {
        case .openai:
            return Model.openAIModels
        case .openrouter:
            return Model.openRouterModels
        case .custom:
            return Model.customModels
        }
    }
}
