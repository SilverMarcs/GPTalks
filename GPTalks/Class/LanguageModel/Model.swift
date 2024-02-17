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
    
    case dalle3
    case dalle2
    
    case gpt4vision

    /// openrouter
    case ortoppy
    case orphind
    case orperplexity
    case orgemini
    case ormixtral
    case ordolphin
    
    /// shuttle
    case shuttleTurbo
    case sgpt4bing
    case sgeminipro
    case smixtral
    case sdolphin
    case spplx7bonline
    case spplx70bonline
    
    /// oxygen
    case ogpt4browsing
    case odolphin
    
    /// gpt4free
    case phind
    case bing
    case gemini
    
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
            
        case .phind, .orphind:
            "Phind"
        case .ortoppy:
            "Toppy 7B"
        case .orperplexity:
            "Pplx Online"
        case .orgemini:
            "Gemini"
        case .ormixtral:
            "Mixtral 8x7B"
        case .ordolphin:
            "Dolphin Mixtral"
        case .bing:
            "Bing"
        case .gemini:
            "Gemini"

        case .shuttleTurbo:
            "Shuttle"
        case .sgpt4bing:
            "Bing"
        case .sgeminipro:
            "Gemini"
        case .smixtral:
            "Mixtral"
        case .sdolphin:
            "Dolphin"
        case .spplx7bonline:
            "PPLX-7B"
        case .spplx70bonline:
            "PPLX-70B"

        case .ogpt4browsing:
            "GPT-4B"
        case .odolphin:
            "Dolphin"
            
        case .dalle3:
            "DALL-E-3"
        case .dalle2:
            "DALL-E-2"

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
            
        case .ortoppy:
            "undi95/toppy-m-7b:free"
        case .orperplexity:
            "perplexity/pplx-7b-online"
        case .orphind:
            "phind/phind-codellama-34b"
        case .orgemini:
            "google/gemini-pro"
        case .ormixtral:
            "nousresearch/nous-hermes-2-mixtral-8x7b-dpo"
        case .ordolphin:
            "cognitivecomputations/dolphin-mixtral-8x7b"
            
        case .phind:
            "phind"
        case .bing:
            "bing"
        case .gemini:
            "gemini"
            
        case .ogpt4browsing:
            "gpt-4-browsing"
        case .odolphin:
            "dolphin-2.6-mixtral-8x7b"
            
        case .shuttleTurbo:
            "shuttle-turbo"
        case .sgpt4bing:
            "gpt-4-bing"
        case .sgeminipro:
            "gemini-pro"
        case .smixtral:
            "mixtral-8x7b"
        case .sdolphin:
            "dolphin-mixtral-8x7b"
        case .spplx7bonline:
            "pplx-7b-online"
        case .spplx70bonline:
            "pplx-70b-online"
            
        case .dalle3:
            "Dall-e-3"
        case .dalle2:
            "Dall-e-2"

        case .customChat:
            AppConfiguration.shared.customModel
        case .customVision:
            AppConfiguration.shared.customVisionModel
        case .customImage:
            AppConfiguration.shared.defaultImageModel
        }
    }
    
//    var supportsChat: Bool {
//        switch self {
//        case .dalle2, .dalle3:
//            false
//        default:
//            false
//        }
//    }
//    
//    var supportsVision: Bool {
//        switch self {
//        case .gpt4vision:
//            true
//        default:
//            false
//        }
//    }
    
    
    static var nonStreamModels: [Model] = [.gemini]

    static let openAIModels: [Model] =
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
    
    static let openRouterModels: [Model] =
        [
            .ortoppy,
            .orperplexity,
            .orphind,
            .orgemini,
            .ordolphin,
        ] + [.customChat]
    
    static let customImageModels: [Model] = [.customImage]
    
    static let customVisionModels: [Model] = [.customVision]
    
    static let shuttleModels: [Model] =
        [
            .shuttleTurbo,
            .sgpt4bing,
            .sgeminipro,
            .smixtral,
            .sdolphin,
            .spplx7bonline,
            .spplx70bonline,
        ] + [.customChat]
    static let oxygenModels: [Model] =
        openAIModels +
        [
            .ogpt4browsing,
            .odolphin,
        ] + [.customChat]
    static let gpt4freeModels: [Model] =
        [
            .bing,
            .phind,
            .gemini,
        ]
    static let customModels: [Model] = openAIModels + [.customChat]
}
