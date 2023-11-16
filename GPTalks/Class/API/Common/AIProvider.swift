//
//  AIProvider.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI
import OpenAI

enum AIProvider: String, CaseIterable, Codable {
    case openAI
    case openRouter
    case pAI

    var id: String {
        switch self {
        case .openAI:
            return "openai"
        case .openRouter:
            return "openrouter"
        case .pAI:
            return "pawan"
        }
    }
    
    var config: OpenAI.Configuration {
        switch self {
        case .openAI:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.OAIkey,
                host: "https://api.openai.com"
            )
        case .openRouter:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.ORkey,
                host: "https://openrouter.ai/api",
                additionalHeaders: ["HTTP-Referer" : "https://example.com"]
            )
        case .pAI:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.PAIkey,
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
        case .openAI:
            return Color("greenColor")
        case .openRouter:
            return Color("purpleColor")
        case .pAI:
            return Color("orangeColor")
        }
    }

    var name: String {
        switch self {
        case .openAI:
            return "OpenAI"
        case .openRouter:
            return "OpenRouter"
        case .pAI:
            return "PAI"
        }
    }

    var contextLength: Int {
        switch self {
        case .openAI:
            return AppConfiguration.shared.OAIcontextLength
        case .openRouter:
            return AppConfiguration.shared.ORcontextLength
        case .pAI:
            return AppConfiguration.shared.PAIcontextLength
        }
    }

    var temperature: Double {
        switch self {
        case .openAI:
            return AppConfiguration.shared.OAItemperature
        case .openRouter:
            return AppConfiguration.shared.ORtemperature
        case .pAI:
            return AppConfiguration.shared.PAItemperature
        }
    }

    var systemPrompt: String {
        switch self {
        case .openAI:
            return AppConfiguration.shared.OAIsystemPrompt
        case .openRouter:
            return AppConfiguration.shared.ORsystemPrompt
        case .pAI:
            return AppConfiguration.shared.PAIsystemPrompt
        }
    }

    var preferredModel: Model {
        switch self {
        case .openAI:
            return AppConfiguration.shared.OAImodel
        case .openRouter:
            return AppConfiguration.shared.ORmodel
        case .pAI:
            return AppConfiguration.shared.PAImodel
        }
    }

    var models: [Model] {
        switch self {
        case .openAI:
            return Model.openAIModels
        case .openRouter:
            return Model.openRouterModels
        case .pAI:
            return Model.pAIModels
        }
    }
}
