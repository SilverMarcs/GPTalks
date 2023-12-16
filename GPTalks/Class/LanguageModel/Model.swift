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
        case .ngemini:
            "Gemini"
        case .nmixtral:
            "Mixtral"
        case .bing:
            "Bing"
        }
    }

    var id: String {
        switch self {
        case .phind:
            "gpt-3.5-turbo"
        case .gpt3:
            "gpt-3.5-turbo-1106"
        case .gpt4, .bing:
            "gpt-4-1106-preview"
        case .orzephyr:
            "huggingfaceh4/zephyr-7b-beta"
        case .orperplexity:
            "perplexity/pplx-7b-online"
        case .orphind:
            "phind/phind-codellama-34b"
        case .ngemini:
            "gemini-pro"
        case .nmixtral:
            "mixtral-8x7b"
        }
    }

    static let openAIModels: [Model] =
        [
            .gpt3,
            .gpt4
        ]
    static let openRouterModels: [Model] =
        [
            .orzephyr,
            .orperplexity,
            .orphind
        ]
    static let nagaModels: [Model] = openAIModels + [.ngemini, .nmixtral]
    static let gpt4freeModels: [Model] = [.bing, .phind]
    static let customModels: [Model] = openAIModels
}
