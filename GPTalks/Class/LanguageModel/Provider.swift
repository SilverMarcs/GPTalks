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
    case naga

    var id: String {
        switch self {
        case .openai:
            "openai"
        case .oxygen:
            "oxygen"
        case .naga:
            "naga"
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
        case .naga:
            OpenAI.Configuration(
                token: AppConfiguration.shared.Nkey,
                host: "api.naga.ac"
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
        case .naga:
            Color("blueColor")
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
        case .naga:
            "Naga"
        case .custom:
            "Custom"
        }
    }

    var preferredChatModel: Model {
        switch self {
        case .openai:
            AppConfiguration.shared.OAImodel
        case .oxygen:
            AppConfiguration.shared.Omodel
        case .custom:
            .customChat
        case .naga:
            AppConfiguration.shared.Nmodel
        }
    }
    
    var preferredImageModel: Model {
        switch self {
        case .openai:
            AppConfiguration.shared.OAIImageModel
        case .oxygen:
            AppConfiguration.shared.OImageModel
        case .custom:
            .customImage
        case .naga:
            AppConfiguration.shared.NImageModel
        }
    }
    
    var preferredVisionModel: Model {
        switch self {
        case .openai:
            .gpt4vision
        case .oxygen:
            .gpt4vision
        case .custom:
            .customVision
        case .naga:
            .gpt4vision
        }
    }

    var chatModels: [Model] {
        switch self {
        case .openai:
            Model.openAIChatModels
        case .oxygen:
            Model.oxygenChatModels
        case .naga:
            Model.nagaChatModels
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
        case .naga:
            Model.nagaVisionModels
        case .custom:
            [Model.customVision]
        }
    }
    
    var imageModels: [Model] {
        switch self {
        case .openai:
            Model.openAIImageModels
        case .oxygen:
            Model.oxygenImageModels
        case .naga:
            Model.nagaImageModels
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
                chatModel: configuration.$OAImodel,
                imageModel: configuration.$OAIImageModel,
                apiKey: configuration.$OAIkey,
                provider: self
            )
        case .oxygen:
            ServiceSettingsView(
                chatModel: configuration.$Omodel,
                imageModel: configuration.$OImageModel,
                apiKey: configuration.$Okey,
                provider: self
            )
        case .naga:
            ServiceSettingsView(
                chatModel: configuration.$Nmodel,
                imageModel: configuration.$NImageModel,
                apiKey: configuration.$Nkey,
                provider: self
            )
        case .custom:
            ServiceSettingsView(
                chatModel: Binding.constant(.customChat),
                imageModel: Binding.constant(.customImage),
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
            .naga,
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
