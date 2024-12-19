//
//  AIProvider.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import OpenAI
import SwiftUI

enum ProviderColor: String, CaseIterable {
    case greenColor = "greenColor"
    case niceColor = "niceColor"
    case blueColor = "blueColor"
    case tealColor = "tealColor"
    case orangeColor = "orangeColor"
    case pinkColor = "pinkColor"
//    case purpleColor = "purpleColor"
    
    var name: String {
        switch self {
        case .greenColor:
            return "Green"
        case .niceColor:
            return "Purple"
        case .blueColor:
            return "Blue"
        case .tealColor:
            return "Teal"
        case .orangeColor:
            return "Orange"
        case .pinkColor:
            return "Pink"
        }
    }
}

enum Provider: String, CaseIterable, Codable, Identifiable {
    case openai
    case custom

    var id: String {
        switch self {
        case .openai:
            return "openai"
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
        case .custom:
            return OpenAI.Configuration(
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
            return Color(AppConfiguration.shared.OAIColor.rawValue)
        case .custom:
            return Color(AppConfiguration.shared.CColor.rawValue)
        }
    }

    var name: String {
        switch self {
        case .openai:
            return "OpenAI"
        case .custom:
            return "Custom"
        }
    }

    var preferredChatModel: Model {
        switch self {
        case .openai:
            return AppConfiguration.shared.OAImodel
        case .custom:
            return AppConfiguration.shared.Cmodel
        }
    }

    var preferredImageModel: Model {
        switch self {
        case .openai:
            return AppConfiguration.shared.OAIImageModel
        case .custom:
            return AppConfiguration.shared.CImageModel
        }
    }
    var chatModels: [Model] {
        switch self {
        case .openai:
            return Model.openAIChatModels
        case .custom:
            return [Model.customChat]
        }
    }
    
    var imageModels: [Model] {
        switch self {
        case .openai:
            return Model.openAIImageModels
        case .custom:
            return Model.openAIImageModels + [Model.customImage]
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
                color: configuration.$OAIColor,
                provider: self
            )
        case .custom:
            ServiceSettingsView(
                chatModel: configuration.$Cmodel,
                imageModel: configuration.$CImageModel,
                apiKey: configuration.$Ckey,
                color: configuration.$CColor,
                provider: self
            )
        }
    }

    var settingsLabel: some View {
        HStack {
            ProviderImage(color: accentColor, frame: frame)
            Text(name)
        }
        .id(accentColor)
    }

    static var availableProviders: [Provider] {
        [
            .openai,
            .custom,
        ]
    }

    var logoImage: some View {
        ProviderImage(radius: imageRadius, color: accentColor, frame: imageSize)
            .id(accentColor)
    }

    private var imageRadius: CGFloat {
        #if os(macOS)
            9
        #else
            16
        #endif
    }

    private var imageSize: CGFloat {
        #if os(macOS)
            23
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
