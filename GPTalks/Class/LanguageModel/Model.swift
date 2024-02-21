//
//  Model.swift
//  GPTalks
//
//  Created by Zabir Raihan on 11/11/2023.
//

import Foundation
import OpenAI

enum Model: String, Codable {
    /// openai
    case gpt3t0125
    case gpt4
    case gpt4t1106
    case gpt4t0125
    
    case gpt4vision
    
    case dalle3
    case dalle2
    
    /// oxygen
    case ogpt4browsing
    case odolphin
    
    case absolutereality_v181
    
    /// custom
    case customChat
    case customVision
    case customImage

    var name: String {
        switch self {
        case .gpt3t0125:
            "GPT-3.5T"
        case .gpt4:
            "GPT-4"
        case .gpt4t1106:
            "GPT-4T (Old)"
        case .gpt4t0125:
            "GPT-4T"
        case .gpt4vision:
            "GPT-4V"
        case .dalle3:
            "DALL·E·3"
        case .dalle2:
            "DALL·E·2"
     
        case .ogpt4browsing:
            "GPT-4B"
        case .odolphin:
            "Dolphin"
        case .absolutereality_v181:
            "Absolute Reality"
            

        case .customChat:
            "Custom"
        case .customVision:
            "Custom Vision"
        case .customImage:
            "Custom Image"

        }
    }

    var id: String {
        switch self {
        case .gpt3t0125:
            "gpt-3.5-turbo-1106"
        case .gpt4:
            "gpt-4"
        case .gpt4t1106:
            "gpt-4-1106-preview"
        case .gpt4t0125:
            "gpt-4-0125-preview"
        case .gpt4vision:
            "gpt-4-vision-preview"

        case .ogpt4browsing:
            "gpt-4-browsing"
        case .odolphin:
            "dolphin-2.6-mixtral-8x7b"
        case .absolutereality_v181:
            "absolutereality_v181"

        case .dalle3:
            "dall-e-3"
        case .dalle2:
            "dall-e-2"

        case .customChat:
            AppConfiguration.shared.customChatModel
        case .customVision:
            AppConfiguration.shared.customVisionModel
        case .customImage:
            AppConfiguration.shared.defaultImageModel
        }
    }

    static let openAIChatModels: [Model] =
        [
            .gpt3t0125,
            .gpt4,
            .gpt4t1106,
            .gpt4t0125,
        ]
    
    static let openAIVisionModels: [Model] =
        [
            .gpt4vision,
        ]
    
    static let openAIImageModels: [Model] =
        [
            .dalle3,
            .dalle2,
        ]
    
    static let oxygenChatModels: [Model] =
        openAIChatModels +
        [
            .ogpt4browsing,
            .odolphin,
        ] + [.customChat]
    
    static let oxygenVisionModels: [Model] =
        openAIVisionModels
    
    static let oxygenImageModels: [Model] =
        openAIImageModels +
        [
            .absolutereality_v181,
        ]
}
