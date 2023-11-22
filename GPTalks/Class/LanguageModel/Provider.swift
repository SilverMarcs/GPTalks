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
    case bing
    case custom

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
        case .custom:
            return "custom"
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
        case .custom:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Ckey,
                host: "https://api.mandrillai.tech"
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
        case .custom:
            return Color(.systemCyan)
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
        case .bing:
            return AppConfiguration.shared.Bmodel
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
        case .bing:
            return [.gpt4]
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
                models: self.models,
                navigationTitle: "OpenAI"
            )
        case .openrouter:
            ServiceSettingsView(
                model: configuration.$ORmodel,
                apiKey: configuration.$ORkey,
                models: self.models,
                navigationTitle: "OpenRouter"
            )
        case .naga:
            ServiceSettingsView(
                model: configuration.$Nmodel,
                apiKey: configuration.$Nkey,
                models: self.models,
                navigationTitle: "NagaAI"
            )
        case .bing:
            ServiceSettingsView(
                model: configuration.$Bmodel,
                apiKey: configuration.$Bkey,
                models: self.models,
                navigationTitle: "Bing"
            )
        case .custom:
            ServiceSettingsView(
                model: configuration.$Bmodel,
                apiKey: configuration.$Bkey,
                models: self.models,
                navigationTitle: "Custom"
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
