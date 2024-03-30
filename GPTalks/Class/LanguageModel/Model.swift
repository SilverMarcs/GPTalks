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
    case whisper1
    
    /// claude
    case claude3opus
    case claude3sonnet
    case claude3haiku
    
    /// oxygen
    case absolutereality_v181

    /// naga
    case sdxl
    case playgroundv25
    
    /// shard
    case realisticvision
    
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
        case .whisper1:
            "Whisper"
            
        /// claude
        case .claude3opus:
            "Claude-3-O"
        case .claude3sonnet:
            "Claude-3-S"
        case .claude3haiku:
            "Claude-3-H"
     
        /// oxygen
        case .absolutereality_v181:
            "Absolute Reality"
            
        /// shard
        case .realisticvision:
            "Realistic Vision"
            
        /// naga
        case .sdxl:
            "SDXL"
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
        case .whisper1:
            "whisper-1"
            
        case .claude3opus:
            "claude-3-opus"
        case .claude3sonnet:
            "claude-3-sonnet"
        case .claude3haiku:
            "claude-3-haiku"

        /// oxygen
        case .absolutereality_v181:
            "absolutereality_v181"
            
        /// shard
        case .realisticvision:
            "realistic-vision-v5"
            
        /// naga
        case .sdxl:
            "sdxl"
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
    
    static let claudeModels: [Model] =
        [
            .claude3opus,
            .claude3sonnet,
            .claude3haiku,
        ]

    /// OpenAI
    static let openAIChatModels: [Model] =
        [
            .gpt3t,
            .gpt4,
            .gpt4t,
//            .customChat
        ]
    
    static let openAIVisionModels: [Model] =
        [
            .gpt4vision,
//            .customVision
        ]
    
    static let openAIImageModels: [Model] =
        [
            .dalle3,
//            .customImage
        ]
    
    /// Oxygen
    static let oxygenChatModels: [Model] =
        openAIChatModels
    
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
        claudeModels
    
    static let nagaVisionModels: [Model] =
        openAIVisionModels
    
    static let nagaImageModels: [Model] =
        openAIImageModels +
        [
            .sdxl,
            .playgroundv25,
        ]
    
    /// Kraken
    static let krakenChatModels: [Model] =
        openAIChatModels +
        claudeModels
    
    static let krakenVisionModels: [Model] =
        openAIVisionModels
    
    static let krakenImageModels: [Model] =
        openAIImageModels +
        [
            .sdxl,
        ]
    
    /// shard
    static let shardChatModels: [Model] =
        openAIChatModels +
        claudeModels
    
    static let shardVisionModels: [Model] =
        openAIVisionModels
    
    static let shardImageModels: [Model] =
        openAIImageModels +
        [
            .realisticvision,
            .sdxl,
        ]
}
