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
    case gpt4o
    case gpt4
    case gpt4t
    case gpt4tp
    case gpt4t1106
    case gpt4t0125
    case gpt4vision
    case dalle3
    case whisper1
    
    /// claude
    case claude3opus
    case claude3sonnet
    case claude3haiku
    
    // ----- //
    
    case sdxl
    
    /// oxygen
    case epic_realism
    case icbinp

    /// naga
    case nplaygroundv25
    case nsd3
    case nkandinsky3_1
    case ngemini
    case nllama3
    case nmixtral
    
    /// kraken
    case kplaygroundv25
    
    /// shard
    case swhisper
    case realisticvision
    case cyberrealistic_v33
    case juggernaut_aftermath
    case am_i_real
    case absolute_reality
    case pollinations
    case midjourney
    
    /// custom
    case customChat
    case customVision
    case customImage

    var name: String {
        switch self {
        case .gpt3t:
            "GPT-3.5T"
        case .gpt4o:
            "GPT-4O"
        case .gpt4:
            "GPT-4"
        case .gpt4t:
            "GPT-4T"
        case .gpt4tp:
            "GPT-4TP"
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
        case .epic_realism:
            "Epic Realism"
        case .icbinp:
            "ICBINP"
            
        /// shard
        case .swhisper:
            "Whisper"
        case .realisticvision:
            "Realistic Vision"
        case .cyberrealistic_v33:
            "Cyber Realistic"
        case .juggernaut_aftermath:
            "Juggernaut Aftermath"
        case .am_i_real:
            "Am I Real"
        case .absolute_reality:
            "Absolute Reality"
        case .pollinations:
            "Pollinations"
        case .midjourney:
            "Midjourney"
            
        /// naga
        case .nplaygroundv25:
            "Playground"
        case .nsd3:
            "SD3"
        case .nkandinsky3_1:
            "Kandinsky-3"
        case .ngemini:
            "Gemini-1.5"
        case .nllama3:
            "Llama-3"
        case .nmixtral:
            "Mixtral"
            
        /// kraken
        case .kplaygroundv25:
            "Playground"
            
        case .sdxl:
            "SDXL"

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
        case .gpt4o:
            "gpt-4o"
        case .gpt4:
            "gpt-4"
        case .gpt4t:
            "gpt-4-turbo-2024-04-09"
        case .gpt4tp:
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
        case .epic_realism:
            "epicrealism_naturalsinrc1vae"
        case .icbinp:
            "icantbelieveitsnotphotography_seco"
            
        /// shard
        case .swhisper:
            "whisper"
        case .realisticvision:
            "realistic-vision-v5"
        case .cyberrealistic_v33:
            "cyberrealistic-v3.3"
        case .juggernaut_aftermath:
            "juggernaut-aftermath"
        case .am_i_real:
            "am-i-real-v4.1"
        case .absolute_reality:
            "absolute-reality-v1.8.1"
        case .pollinations:
            "pollinations"
        case .midjourney:
            "midjourney"
            
        /// naga
        case .nplaygroundv25:
            "playground-v2.5"
        case .nsd3:
            "stable-diffusion-3"
        case .nkandinsky3_1:
            "kandinsky-3.1"
        case .ngemini:
            "gemini-1.5-pro-latest"
        case .nllama3:
            "llama-3-70b-instruct"
        case .nmixtral:
            "mixtral-8x22b-instruct"
            
        /// kraken
        case .kplaygroundv25:
            "playground-2.5"
            
        case .sdxl:
            "sdxl"

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
            .gpt4o,
            .gpt4t,
            .gpt4tp,
        ]
    
    static let openAIVisionModels: [Model] =
        [
            .gpt4vision,
        ]
    
    static let openAIImageModels: [Model] =
        [
            .dalle3,
        ]
    
    /// Oxygen
    static let oxygenChatModels: [Model] =
        openAIChatModels +
        claudeModels
    
    static let oxygenVisionModels: [Model] =
        openAIVisionModels
    
    static let oxygenImageModels: [Model] =
        openAIImageModels +
        [
            .epic_realism,
            .icbinp,
        ]
    
    /// Naga
    static let nagaChatModels: [Model] =
        openAIChatModels +
        claudeModels +
        [
            .ngemini,
            .nllama3,
            .nmixtral,
        ]
    
    static let nagaVisionModels: [Model] =
        openAIVisionModels
    
    static let nagaImageModels: [Model] =
        openAIImageModels +
        [
            .sdxl,
            .nplaygroundv25,
            .nsd3,
            .nkandinsky3_1,
        ]
    
    /// Mandril
    static let mandrilChatModels: [Model] =
        openAIChatModels +
        claudeModels
    
    static let mandrilVisionModels: [Model] =
        openAIVisionModels
    
    static let mandrilImageModels: [Model] =
        openAIImageModels +
        [
            .sdxl,
            .nplaygroundv25,
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
            .kplaygroundv25,
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
            .midjourney,
            .realisticvision,
            .sdxl,
            .cyberrealistic_v33,
            .juggernaut_aftermath,
            .am_i_real,
            .absolute_reality,
            .pollinations,
        ]
}
