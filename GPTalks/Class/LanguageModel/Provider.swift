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
    case oxygen
    case custom

    var id: String {
        switch self {
        case .openai:
            "openai"
        case .oxygen:
            "oxygen"
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
        case .oxygen:
            OpenAI.Configuration(
                token: AppConfiguration.shared.Okey,
                host: "app.oxyapi.uk"
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
        case .oxygen:
            Color("niceColor")
        case .custom:
            Color("tealColor")
        }
    }

    var name: String {
        switch self {
        case .openai:
            "OpenAI"
        case .oxygen:
            "Oxygen"
        case .custom:
            "Custom"
        }
    }

    var preferredModel: Model {
        switch self {
        case .openai:
            AppConfiguration.shared.OAImodel
        case .oxygen:
            AppConfiguration.shared.Omodel
        case .custom:
            AppConfiguration.shared.Cmodel
        }
    }

    var chatModels: [Model] {
        switch self {
        case .openai:
            Model.openAIChatModels
        case .oxygen:
            Model.oxygenChatModels + [Model.customChat]
        case .custom:
            [Model.customChat]
        }
    }
    
    var visionModels: [Model] {
        switch self {
        case .openai:
            Model.openAIVisionModels
        case .oxygen:
            Model.oxygenVisionModels
        case .custom:
            [Model.customVision]
        }
    }
    
    var imageModels: [Model] {
        switch self {
        case .openai:
            Model.openAIImageModels
        case .oxygen:
            Model.oxygenImageModels + [Model.customImage]
        case .custom:
            [Model.customImage]
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
        case .oxygen:
            ServiceSettingsView(
                model: configuration.$Omodel,
                apiKey: configuration.$Okey,
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
            .oxygen,
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
