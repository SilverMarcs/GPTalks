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
    case naga
    case bing
//    case ca

    var id: String {
        switch self {
        case .openai:
            return "openai"
        case .openrouter:
            return "openrouter"
        case .naga:
            return "naga"
        case .bing:
            return "bing"
        }
    }
    
//    func config(keys: [String: String]) -> OpenAI.Configuration {
//        switch self {
//        case .openai:
//            return OpenAI.Configuration(
//                token: AppConfiguration.shared.OAIkey,
//                host: "https://api.openai.com"
//            )
//        case .openrouter:
//            return OpenAI.Configuration(
//                token: AppConfiguration.shared.ORkey,
//                host: "https://openrouter.ai/api"
//            )
//        case .custom:
//            return OpenAI.Configuration(
//                token: "WVoJofdvnvpWNB1uJL6q6NdSjjf4v5_F1Zld_6mtxno",
//                host: "https://api.naga.ac"
//            )
//        case .custom2:
//            return OpenAI.Configuration(
//                token: AppConfiguration.shared.C2key,
//                host: "AppConfiguration.shared.C2host"
//            )
//        }
//    }
    
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
                additionalHeaders: ["HTTP-Referer": "www.github.com/SilverMarcs"]
            )
        case .naga:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Nkey,
                host: "https://api.naga.ac"
            )
        case .bing:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Bkey,
                host: "https://api.shuttleai.app"
            )
        }
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
        case .naga:
            return Color("orangeColor")
        case .bing:
            return .accentColor
        }
    }

    var name: String {
        switch self {
        case .openai:
            return "OpenAI"
        case .openrouter:
            return "OpenRouter"
        case .naga:
            return "NagaAI"
        case .bing:
            return "Bing"
        }
    }
    
    var preferredModel: Model {
        switch self {
        case .openai:
            return AppConfiguration.shared.OAImodel
        case .openrouter:
            return AppConfiguration.shared.ORmodel
        case .naga:
            return AppConfiguration.shared.Nmodel
        case .bing:
            return .gpt4
        }
    }

    var models: [Model] {
        switch self {
        case .openai:
            return Model.openAIModels
        case .openrouter:
            return Model.openRouterModels
        case .naga:
            return Model.nagaModels
        case .bing:
            return [.gpt4]
        }
    }
}
