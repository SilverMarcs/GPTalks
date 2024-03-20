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
    case gpt3t
    case gpt4
    case gpt4t
    case gpt4t1106
    case gpt4t0125
    
    case gpt4vision
    
    case dalle3
    case dalle2
    
    /// oxygen
    case ogpt4browsing
    case odolphin
    
    case absolutereality_v181
    
    /// naga
    case mistrallarge
    case geminipro
    case geminiprovision
    
    /// claude
    case claude3opus
    case claude3sonnet
    case claude3haiku
    
    case sdxl
    case kandinsky3
    case playgroundv25
    
    
    /// custom
    case customChat
    case customVision
    case customImage

    var name: String {
        switch self {
        case .gpt3t:
            "GPT-3.5T"
        case .gpt4:
            "GPT-4"
        case .gpt4t:
            "GPT-4T"
        case .gpt4t1106:
            "GPT-4T 1106"
        case .gpt4t0125:
            "GPT-4T 0125"
        case .gpt4vision:
            "GPT-4V"
        case .dalle3:
            "DALL·E·3"
        case .dalle2:
            "DALL·E·2"
     
        /// oxygen
        case .ogpt4browsing:
            "GPT-4B"
        case .odolphin:
            "Dolphin"
        case .absolutereality_v181:
            "Absolute Reality"
            
        /// naga
        case .mistrallarge:
            "Mistral"
        case .geminipro:
            "Gemini"
        case .geminiprovision:
            "Gemini-V"
        case .claude3opus:
            "Claude-3-O"
        case .claude3sonnet:
            "Claude-3-S"
        case .claude3haiku:
            "Claude-3-H"
            
        case .sdxl:
            "SDXL"
        case .kandinsky3:
            "Kandinsky"
        case .playgroundv25:
            "Playground"
            

        case .customChat:
            self.id.isEmpty ? "Custom Chat" : self.id
        case .customVision:
            self.id.isEmpty ? "Custom Vision" : self.id
        case .customImage:
            self.id.isEmpty ? "Custom Image" : self.id


        }
    }

    var id: String {
        switch self {
        case .gpt3t:
            "gpt-3.5-turbo"
        case .gpt4:
            "gpt-4"
        case .gpt4t:
            "gpt-4-turbo-preview"
        case .gpt4t1106:
            "gpt-4-1106-preview"
        case .gpt4t0125:
            "gpt-4-0125-preview"
        case .gpt4vision:
            "gpt-4-vision-preview"
        case .dalle3:
            "dall-e-3"
        case .dalle2:
            "dall-e-2"

        case .ogpt4browsing:
            "gpt-4-browsing"
        case .odolphin:
            "dolphin-2.6-mixtral-8x7b"
        case .absolutereality_v181:
            "absolutereality_v181"
            
        /// naga
        case .mistrallarge:
            "mistral-large"
        case .geminipro:
            "gemini-pro"
        case .geminiprovision:
            "gemini-pro-vision"
            
        case .claude3opus:
            "claude-3-opus"
        case .claude3sonnet:
            "claude-3-sonnet"
        case .claude3haiku:
            "claude-3-haiku"
            
        case .sdxl:
            "sdxl"
        case .kandinsky3:
            "kandinsky-3"
        case .playgroundv25:
            "playground-v2.5"

        case .customChat:
            AppConfiguration.shared.customChatModel
        case .customVision:
            AppConfiguration.shared.customVisionModel
        case .customImage:
            AppConfiguration.shared.customImageModel
        }
    }

    /// OpenAI
    static let openAIChatModels: [Model] =
        [
            .gpt3t,
            .gpt4,
            .gpt4t,
//            .gpt4t1106,
//            .gpt4t0125,
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
    
    /// Oxygen
    static let oxygenChatModels: [Model] =
        openAIChatModels +
        [
            .ogpt4browsing,
            .odolphin,
            .gpt4t0125,
        ]
    
    static let oxygenVisionModels: [Model] =
        openAIVisionModels
    
    static let oxygenImageModels: [Model] =
        openAIImageModels +
        [
            .absolutereality_v181,
        ]
    
    /// Naga
    static let nagaChatModels: [Model] =
        openAIChatModels +
        [
            .claude3opus,
            .claude3sonnet,
            .claude3haiku,
            .mistrallarge,
            .geminipro,
        ]
    
    static let nagaVisionModels: [Model] =
        openAIVisionModels +
        [
            .geminiprovision,
        ]
    
    static let nagaImageModels: [Model] =
        [
            .dalle3,
            .sdxl,
            .kandinsky3,
            .playgroundv25,
        ]
    
    /// Kraken
    static let krakenChatModels: [Model] =
        openAIChatModels +
        [
            .mistrallarge,
            .geminipro,
        ]
    
    static let krakenVisionModels: [Model] =
        openAIVisionModels +
        [
            .geminiprovision,
        ]
    
    static let krakenImageModels: [Model] =
        [
            .dalle3,
            .sdxl,
            .playgroundv25,
        ]
}
