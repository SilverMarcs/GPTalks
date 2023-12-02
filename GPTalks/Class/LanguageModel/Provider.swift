//
//  AIProvider.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI
import OpenAI

enum Provider: String, CaseIterable, Codable, Identifiable {
    case openai
    case openrouter
    case naga
    case gpt4free
    case custom

    var id: String {
        switch self {
        case .openai:
            return "openai"
        case .openrouter:
            return "openrouter"
        case .naga:
            return "naga"
        case .gpt4free:
            return "gpt4free"
        case .custom:
            return "custom"
        }
    }
    
    var config: OpenAI.Configuration {
        switch self {
        case .openai:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.OAIkey,
                host: "api.openai.com"
            )
        case .openrouter:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.ORkey,
                host: "openrouter.ai/api",
                additionalHeaders: ["HTTP-Referer": "www.github.com/SilverMarcs"]
            )
        case .naga:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Nkey,
                host: "api.naga.ac"
            )
        case .gpt4free:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Gkey,
                host: AppConfiguration.shared.Ghost
            )
        case .custom:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Ckey,
                host: AppConfiguration.shared.Chost
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
        case .gpt4free:
            return Color("blueColor")
        case .custom:
            return Color("tealColor")
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
        case .gpt4free:
            return "GPT4Free"
        case .custom:
            return "Custom"
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
        case .gpt4free:
            return AppConfiguration.shared.Gmodel
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
        case .naga:
            return Model.nagaModels
        case .gpt4free:
            return Model.gpt4freeModels
        case .custom:
            return Model.customModels
        }
    }
    
    @ViewBuilder
    var destination: some View {
        @ObservedObject var configuration = AppConfiguration.shared

        switch self {
        case .openai:
            ServiceSettingsView(
                model: configuration.$OAImodel,
                apiKey: configuration.$OAIkey,
                provider: self
            )
        case .openrouter:
            ServiceSettingsView(
                model: configuration.$ORmodel,
                apiKey: configuration.$ORkey,
                provider: self
            )
        case .naga:
            ServiceSettingsView(
                model: configuration.$Nmodel,
                apiKey: configuration.$Nkey,
                provider: self
            )
        case .gpt4free:
            ServiceSettingsView(
                model: configuration.$Gmodel,
                apiKey: configuration.$Gkey,
                provider: self
            )
        case .custom:
            ServiceSettingsView(
                model: configuration.$Cmodel,
                apiKey: configuration.$Ckey,
                provider: self
            )
        }
    }
    
    var label: some View {
        HStack {
            Image(rawValue.lowercased())
                .resizable()
                .cornerRadius(10)
            #if os(macOS)
                .frame(width: 35, height: 35)
            #else
                .frame(width: 30, height: 30)
            #endif
            Text(name)
        }
    }
}
