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
    case gpt3t_16
    case gpt4
    case gpt4t

    /// openrouter
    case orzephyr
    case orpplx7b
    case orgemini

    /// gpt4free
    case phind
    case bing

    /// naga
    case nmixtral

    var name: String {
        switch self {
        case .gpt3t:
            "GPT-3.5"
        case .gpt3t_16:
            "GPT-3.5 16K"
        case .gpt4:
            "GPT-4"
        case .gpt4t:
            "GPT-4 Turbo"
        case .phind:
            "Phind"
        case .orzephyr:
            "Zephyr"
        case .orpplx7b:
            "Perplexity"
        case .bing:
            "Bing"
        case .orgemini:
            "Gemini"
        case .nmixtral:
            "Mixtral"
        }
    }

    var id: String {
        switch self {
        case .gpt3t, .phind:
            "gpt-3.5-turbo"
        case .gpt3t_16:
            "gpt-3.5-turbo-1106"
        case .gpt4, .bing:
            "gpt-4"
        case .gpt4t:
            "gpt-4-1106-preview"
        case .orzephyr:
            "huggingfaceh4/zephyr-7b-beta"
        case .orgemini:
            "google/gemini-pro"
        case .orpplx7b:
            "perplexity/pplx-7b-online"
        case .nmixtral:
            "mixtral-8x7b"
        }
    }

    static let openAIModels: [Model] =
        [
            .gpt3t,
            .gpt3t_16,
            .gpt4,
            .gpt4t,
        ]
    static let openRouterModels: [Model] =
        [
            .orzephyr,
            .orgemini,
            .orpplx7b,
        ]
    static let nagaModels: [Model] = openAIModels + [.nmixtral]
    static let gpt4freeModels: [Model] = [.bing, .phind]
    static let customModels: [Model] = openAIModels
}
