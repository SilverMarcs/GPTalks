//
//  Model.swift
//  GPTalks
//
//  Created by Zabir Raihan on 11/11/2023.
//

import Foundation

enum Model: String, Codable {
    /// openai
    case gpt3
    case gpt4

    /// openrouter
    case phind
    case codellama
    case mistral
    case mythomax
    case palm
    case palmcode
    case zephyr
    case orgpt3
    case orgpt4

    /// pawan
    case pai
    case pailight

    var name: String {
        switch self {
        case .gpt3, .orgpt3:
            return "GPT-3"
        case .gpt4, .orgpt4:
            return "GPT-4"
        case .phind:
            return "Phind"
        case .codellama:
            return "CodeLlama"
        case .mistral:
            return "Mistral"
        case .mythomax:
            return "MythoMax"
        case .palm:
            return "Palm"
        case .palmcode:
            return "GCode"
        case .pai:
            return "PAI"
        case .pailight:
            return "PAI-L"
        case .zephyr:
            return "Zephyr"
        }
    }

    var id: String {
        switch self {
        case .gpt3:
            return "gpt-3.5-turbo-1106"
        case .gpt4:
            return "gpt-4-1106-preview"
        case .phind:
            return "phind/phind-codellama-34b-v2"
        case .codellama:
            return "meta-llama/codellama-34b-instruct"
        case .mistral:
            return "open-orca/mistral-7b-openorca"
        case .mythomax:
            return "gryphe/mythomax-l2-13b"
        case .palm:
            return "google/palm-2-chat-bison"
        case .palmcode:
            return "google/palm-2-codechat-bison"
        case .pai:
            return "pai-001-beta"
        case .pailight:
            return "pai-001-light-beta"
        case .zephyr:
            return "huggingfaceh4/zephyr-7b-beta"
        case .orgpt3:
            return "openai/gpt-3.5-turbo-1106"
        case .orgpt4:
            return "openai/gpt-4-1106-preview"
        }
    }

    var maxTokens: Int {
        switch self {
        case .gpt3, .gpt4, .phind, .codellama, .mistral, .mythomax, .pai, .pailight, .zephyr, .orgpt3, .orgpt4:
            return 4000
        case .palm, .palmcode:
            return 2000
        }
    }

    static let openAIModels: [Model] = [.gpt3, .gpt4]
    static let openRouterModels: [Model] = [.phind, .codellama, .mistral, .mythomax, .palm, .palmcode, .zephyr, .orgpt3, .orgpt4]
    static let pAIModels: [Model] = [.pai, .pailight]
}
