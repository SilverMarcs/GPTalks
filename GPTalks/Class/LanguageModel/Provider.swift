//
//  AIProvider.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import OpenAI
import SwiftUI

enum Provider: String, CaseIterable, Codable, Identifiable {
    case openai
    case openrouter
    case shuttle
    case oxygen
    case gpt4free
    case custom

    var id: String {
        switch self {
        case .openai:
            "openai"
        case .openrouter:
            "openrouter"
        case .shuttle:
            "shuttle"
        case .oxygen:
            "oxygen"
        case .gpt4free:
            "gpt4free"
        case .custom:
            "custom"
        }
    }

    var config: OpenAI.Configuration {
        switch self {
        case .openai:
            OpenAI.Configuration(
                token: AppConfiguration.shared.OAIkey,
                host: "api.openai.com"
            )
        case .openrouter:
            OpenAI.Configuration(
                token: AppConfiguration.shared.ORkey,
                host: "openrouter.ai/api"
            )
        case .shuttle:
            OpenAI.Configuration(
                token: AppConfiguration.shared.Skey,
                host: "api.shuttleai.app"
            )
        case .oxygen:
            OpenAI.Configuration(
                token: AppConfiguration.shared.Okey,
                host: "app.oxyapi.uk"
            )
        case .gpt4free:
            OpenAI.Configuration(
                token: AppConfiguration.shared.Gkey,
                host: AppConfiguration.shared.Ghost
            )
        case .custom:
            OpenAI.Configuration(
                token: AppConfiguration.shared.Ckey,
                host: AppConfiguration.shared.Chost
            )
        }
    }

    var iconName: String {
        rawValue.lowercased()
    }

    var accentColor: Color {
        switch self {
        case .openai:
            Color("greenColor")
        case .openrouter:
            Color("pinkColor")
        case .shuttle:
            Color("purpleColor")
        case .oxygen:
            Color("niceColor")
        case .gpt4free:
            Color("blueColor")
        case .custom:
            Color("tealColor")
        }
    }

    var name: String {
        switch self {
        case .openai:
            "OpenAI"
        case .openrouter:
            "OpenRouter"
        case .shuttle:
            "Shuttle"
        case .oxygen:
            "Oxygen"
        case .gpt4free:
            "GPT4Free"
        case .custom:
            "Custom"
        }
    }

    var preferredModel: Model {
        switch self {
        case .openai:
            AppConfiguration.shared.OAImodel
        case .openrouter:
            AppConfiguration.shared.ORmodel
        case .shuttle:
            AppConfiguration.shared.Smodel
        case .oxygen:
            AppConfiguration.shared.Omodel
        case .gpt4free:
            AppConfiguration.shared.Gmodel
        case .custom:
            AppConfiguration.shared.Cmodel
        }
    }

    var chatModels: [Model] {
        switch self {
        case .openai:
            Model.openAIModels
        case .openrouter:
            Model.openRouterModels
        case .shuttle:
            Model.shuttleModels
        case .oxygen:
            Model.oxygenModels
        case .gpt4free:
            Model.gpt4freeModels
        case .custom:
            Model.customModels
        }
    }
    
    var visionModels: [Model] {
        switch self {
        case .openai:
            Model.openAIVisionModels
        case .openrouter:
//            Model.openRouterVisionModels
            Model.customVisionModels
        case .shuttle:
//            Model.shuttleVisionModels
            Model.customVisionModels
        case .oxygen:
//            Model.oxygenVisionModels
            Model.openAIVisionModels
        case .gpt4free:
//            Model.gpt4freeVisionModels
            Model.customVisionModels
        case .custom:
//            Model.customVisionModels
            Model.openAIVisionModels
        }
    }
    
    var imageModels: [Model] {
        switch self {
        case .openai:
            Model.openAIImageModels
        case .openrouter:
//            Model.openRouterImageModels
            Model.customImageModels
        case .shuttle:
//            Model.shuttleImageModels
            Model.customImageModels
        case .oxygen:
//            Model.oxygenImageModels
            Model.customImageModels
        case .gpt4free:
//            Model.gpt4freeImageModels
            Model.customImageModels
        case .custom:
//            Model.customImageModels
            Model.customImageModels
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
        case .shuttle:
            ServiceSettingsView(
                model: configuration.$Smodel,
                apiKey: configuration.$Skey,
                provider: self
            )
        case .oxygen:
            ServiceSettingsView(
                model: configuration.$Omodel,
                apiKey: configuration.$Okey,
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

    var settingsLabel: some View {
        HStack {
            ProviderImage(color: self.accentColor, frame: frame)
            Text(name)
        }
    }

    static var availableProviders: [Provider] {
        [
            .openai,
            .openrouter,
            .shuttle,
            .oxygen,
//            .gpt4free,
            .custom,
        ]
    }

    var logoImage: some View {
        ProviderImage(radius: imageRadius, color: accentColor, frame: imageSize)
    }

    private var imageRadius: CGFloat {
        #if os(macOS)
            11
        #else
            16
        #endif
    }

    private var imageSize: CGFloat {
        #if os(macOS)
            36
        #else
            50
        #endif
    }

    private var frame: CGFloat {
        #if os(macOS)
            35
        #else
            30
        #endif
    }
}
