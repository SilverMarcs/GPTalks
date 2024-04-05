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
    case kraken
    case shard // Newly added case

    var id: String {
        switch self {
        case .openai:
            return "openai"
        case .oxygen:
            return "oxygen"
        case .naga:
            return "naga"
        case .kraken:
            return "kraken"
        case .custom:
            return "custom"
        case .shard: 
            return "shard"
        }
    }

    var config: OpenAI.Configuration {
        switch self {
        case .openai:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.OAIkey,
                host: "api.openai.com"
            )
        case .oxygen:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Okey,
                host: "app.oxyapi.uk"
            )
        case .naga:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Nkey,
                host: "api.naga.ac"
            )
        case .kraken:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Kkey,
                host: "api.cracked.systems"
            )
        case .custom:
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Ckey,
                host: AppConfiguration.shared.Chost
            )
        case .shard: 
            return OpenAI.Configuration(
                token: AppConfiguration.shared.Skey,
                host: "api.shard-ai.xyz"
            )
        }
    }

    var iconName: String {
        rawValue.lowercased()
    }

    var accentColor: Color {
        switch self {
        case .openai:
            return Color("greenColor")
        case .oxygen:
            return Color("niceColor")
//            return Color("tealColor")
        case .naga:
            return Color("blueColor")
        case .kraken:
//            return Color("pinkColor")
            return Color("tealColor")
        case .custom:
            return Color("orangeColor")
        case .shard: 
//            return Color("niceColor")
            return Color("pinkColor")
        }
    }

    var name: String {
        switch self {
        case .openai:
            return "OpenAI"
        case .oxygen:
            return "Oxygen"
        case .naga:
            return "Naga"
        case .kraken:
            return "Kraken"
        case .custom:
            return "Custom"
        case .shard: 
            return "Shard"
        }
    }

    var preferredChatModel: Model {
        switch self {
        case .openai:
            return AppConfiguration.shared.OAImodel
        case .oxygen:
            return AppConfiguration.shared.Omodel
        case .naga:
            return AppConfiguration.shared.Nmodel
        case .kraken:
            return AppConfiguration.shared.Kmodel
        case .custom:
            return AppConfiguration.shared.Cmodel
        case .shard: 
            return AppConfiguration.shared.Smodel
        }
    }
    
    var preferredImageModel: Model {
        switch self {
        case .openai:
            return AppConfiguration.shared.OAIImageModel
        case .oxygen:
            return AppConfiguration.shared.OImageModel
        case .naga:
            return AppConfiguration.shared.NImageModel
        case .kraken:
            return AppConfiguration.shared.KImageModel
        case .custom:
            return AppConfiguration.shared.CImageModel
        case .shard: 
            return AppConfiguration.shared.SImageModel
        }
    }
    
    var preferredVisionModel: Model {
        switch self {
        case .openai, .oxygen, .naga, .kraken, .custom, .shard:
            return .gpt4vision
        }
    }
    
    var preferredTranscriptionModel: Model {
        switch self {
        case .openai, .oxygen, .naga, .kraken, .custom, .shard:
            return .whisper1
        }
    }

    var chatModels: [Model] {
        switch self {
        case .openai:
            return Model.openAIChatModels
        case .oxygen:
            return Model.oxygenChatModels
        case .naga:
            return Model.nagaChatModels
        case .kraken:
            return Model.krakenChatModels
        case .custom:
            return Model.nagaChatModels + [Model.customChat]
        case .shard:
            return Model.shardChatModels
        }
    }
    
    var visionModels: [Model] {
        switch self {
        case .openai:
            return Model.openAIVisionModels
        case .oxygen:
            return Model.oxygenVisionModels
        case .naga:
            return Model.nagaVisionModels
        case .kraken:
            return Model.krakenVisionModels
        case .custom:
            return Model.openAIVisionModels + [Model.customVision]
        case .shard:
            return Model.shardVisionModels
        }
    }
    
    var imageModels: [Model] {
        switch self {
        case .openai:
            return Model.openAIImageModels
        case .oxygen:
            return Model.oxygenImageModels
        case .naga:
            return Model.nagaImageModels
        case .kraken:
            return Model.krakenImageModels
        case .custom:
            return Model.openAIImageModels + [Model.customImage]
        case .shard:
            return Model.shardImageModels
        }
    }
    
    var transcriptionModels: [Model] {
        switch self {
        case .openai, .oxygen, .naga, .kraken, .custom:
            return [.whisper1]
        case .shard:
            return [.swhisper,]
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
        case .kraken:
            ServiceSettingsView(
                chatModel: configuration.$Kmodel,
                imageModel: configuration.$KImageModel,
                apiKey: configuration.$Kkey,
                provider: self
            )
        case .custom:
            ServiceSettingsView(
                chatModel: configuration.$Cmodel,
                imageModel: configuration.$CImageModel,
                apiKey: configuration.$Ckey,
                provider: self
            )
        case .shard:
            ServiceSettingsView(
                chatModel: configuration.$Smodel,
                imageModel: configuration.$SImageModel,
                apiKey: configuration.$Skey,
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
            .kraken,
            .shard,
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
