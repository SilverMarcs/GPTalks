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

    /// openrouter
    case ortoppy
    case orphind
    case orperplexity
    case orgemini
    case ormixtral
    case ordolphin
    
    /// shuttle
    case sgpt3t0125
    case sgpt4
    case sgpt4t
    case sgpt4bing
    case scodegpt3
    case internetgpt3
    case sclaudei
    case sgeminipro
    case smixtral
    case sdolphin
    case spplxonline
    case spplxchat
    

    /// gpt4free
    case phind
    case bing
    case gemini

    var name: String {
        switch self {
        case .gpt3t0125:
            "GPT-3.5T 0125"
        case .gpt4:
            "GPT-4"
        case .gpt4t1106:
            "GPT-4T 1106"
        case .gpt4t0125:
            "GPT-4T 0125"
        case .phind, .orphind:
            "Phind"
        case .ortoppy:
            "Toppy 7B"
        case .orperplexity:
            "Pplx Online"
        case .orgemini:
            "Gemini Pro"
        case .ormixtral:
            "Mixtral 8x7B"
        case .ordolphin:
            "Dolphin Mixtral"
        case .bing:
            "Bing"
        case .gemini:
            "Gemini"
            
        case .sgpt3t0125:
            "GPT-3.5T 0125"
        case .sgpt4:
            "GPT-4"
        case .sgpt4t:
            "GPT-4T"
        case .sgpt4bing:
            "Bing"
        case .scodegpt3:
            "GPT3-C"
        case .internetgpt3:
            "GPT3-I"
        case .sclaudei:
            "Claude-1"
        case .sgeminipro:
            "Gemini Pro"
        case .smixtral:
            "Mixtral"
        case .sdolphin:
            "Dolphin"
        case .spplxonline:
            "Pplx Online"
        case .spplxchat:
            "Pplx Chat"
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
            
        case .sgpt3t0125:
            "gpt-3.5-turbo-0125"
        case .sgpt4:
            "gpt-4"
        case .sgpt4t:
            "gpt-4-turbo-preview"
        case .sgpt4bing:
            "gpt-4-bing"
        case .scodegpt3:
            "code-gpt"
        case .internetgpt3:
            "internet-gpt"
        case .sclaudei:
            "claude-instant"
        case .sgeminipro:
            "gemini-pro"
        case .smixtral:
            "mixtral-8x7b"
        case .sdolphin:
            "dolphin-mixtral-8x7b"
        case .spplxonline:
            "pplx-70b-online"
        case .spplxchat:
            "pplx-70b-chat"
        }
    }
    
    static var nonStreamModels: [Model] = [.gemini]

    static let openAIModels: [Model] =
        [
            .gpt3t0125,
            .gpt4,
            .gpt4t1106,
            .gpt4t0125,
        ]
    static let openRouterModels: [Model] =
        [
            .ortoppy,
            .orperplexity,
            .orphind,
            .orgemini,
            .ordolphin,
        ]
    static let shuttleModels: [Model] = 
        [
            .sgpt3t0125,
            .sgpt4,
            .sgpt4t,
            .sgpt4bing,
            .scodegpt3,
            .internetgpt3,
            .sclaudei,
            .sgeminipro,
            .smixtral,
            .sdolphin,
            .spplxonline,
            .spplxchat,
        ]
    static let gpt4freeModels: [Model] =
        [
            .bing,
            .phind,
            .gemini,
        ]
    static let customModels: [Model] = openAIModels
}
