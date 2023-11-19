//
//  AIProvider.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI
import OpenAI

enum Provider: String, CaseIterable, Codable {
    case openai
    case openrouter
    case custom
    case custom2

    var id: String {
        switch self {
        case .openai:
            return "openai"
        case .openrouter:
            return "openrouter"
        case .custom:
            return "custom"
        case .custom2:
            return "custom2"
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
                host: "https://openrouter.ai/api"
            )
        case .custom:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Ckey,
                host: "https://vortex.thatlukinhasguy.xyz"
            )
        case .custom2:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.C2key,
                host: AppConfiguration.shared.C2host
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
        case .custom2:
            return .accentColor
        }
    }

    var name: String {
        switch self {
        case .openai:
            return "OpenAI"
        case .openrouter:
            return "OpenRouter"
        case .custom:
            return "Custom"
        case .custom2:
            return "Custom 2"
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
        case .custom2:
            return AppConfiguration.shared.C2contextLength
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
        case .custom2:
            return AppConfiguration.shared.C2temperature
        }
    }

    var systemPrompt: String {
        switch self {
        case .openai:
            return AppConfiguration.shared.OAIsystemPrompt
        case .openrouter:
            return AppConfiguration.shared.ORsystemPrompt
        case .custom:
            return AppConfiguration.shared.CsystemPrompt
        case .custom2:
            return AppConfiguration.shared.C2systemPrompt
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
        case .custom2:
            return AppConfiguration.shared.C2model
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
        case .custom2:
            return Model.customModels
        }
    }
}
