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
    case gpt3
    case gpt4

    /// openrouter
    case orzephyr
    case orphind
    case orperplexity
    case orgemini
    case ormixtral
    case ordolphin

    /// naga
    case ngemini
    case nmixtral

    /// gpt4free
    case phind
    case bing

    var name: String {
        switch self {
        case .gpt3:
            "GPT-3.5"
        case .gpt4:
            "GPT-4"
        case .phind, .orphind:
            "Phind"
        case .orzephyr:
            "Zephyr"
        case .orperplexity:
            "Perplexity"
        case .ngemini, .orgemini:
            "Gemini"
        case .nmixtral, .ormixtral:
            "Mixtral"
        case .ordolphin:
            "Dolphin"
        case .bing:
            "Bing"

        }
    }

    var id: String {
        switch self {
        case .gpt3:
            "gpt-3.5-turbo-1106"
        case .gpt4:
            "gpt-4-1106-preview"
        case .orzephyr:
            "huggingfaceh4/zephyr-7b-beta"
        case .orperplexity:
            "perplexity/pplx-7b-online"
        case .orphind:
            "phind/phind-codellama-34b"
        case .orgemini:
            "google/gemini-pro"
        case .ormixtral:
            "mistralai/mixtral-8x7b-instruct"
        case .ordolphin:
            "cognitivecomputations/dolphin-mixtral-8x7b"
        case .ngemini:
            "gemini-pro"
        case .nmixtral:
            "mixtral-8x7b"
        case .phind:
            "phind"
        case .bing:
            "bing"
        }
    }

    static let openAIModels: [Model] =
        [
            .gpt3,
            .gpt4,
        ]
    static let openRouterModels: [Model] =
        [
            .orzephyr,
            .orperplexity,
            .orphind,
            .orgemini,
            .ordolphin,
        ]
    static let nagaModels: [Model] = 
        openAIModels + [
            .ngemini, 
            .nmixtral,
        ]
    static let mandrilModels: [Model] = openAIModels
    static let gpt4freeModels: [Model] = [.bing, .phind]
    static let customModels: [Model] = openAIModels
}
