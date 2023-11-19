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
    case orphind
    case orcodellama
    case ormistral
    case ormythomax
    case orpalm
    case orpalmcode
    case orzephyr
    case orgpt3
    case orgpt4t
    case orhermes
    case ortoppy
    
    /// custom
    case claude2
    case claudeinstant

    var name: String {
        switch self {
        case .gpt3t:
            return "GPT-3.5"
        case .gpt3t_16, .orgpt3:
            return "GPT-3.5 16K"
        case .gpt4:
            return "GPT-4"
        case .gpt4t, .orgpt4t:
            return "GPT-4 Turbo"
        case .orphind:
            return "Phind"
        case .orcodellama:
            return "CodeLlama"
        case .ormistral:
            return "Mistral"
        case .ormythomax:
            return "MythoMax"
        case .orpalm:
            return "Palm"
        case .orpalmcode:
            return "GCode"
        case .orzephyr:
            return "Zephyr"
        case .orhermes:
            return "Hermes"
        case .ortoppy:
            return "Toppy"
        case .claude2:
            return "Claude 2"
        case .claudeinstant:
            return "Claude Inst"
        }
    }

    var id: String {
        switch self {
        case .gpt3t:
            return "gpt-3.5-turbo"
        case .gpt3t_16:
            return "gpt-3.5-turbo-1106"
        case .gpt4:
            return "gpt-4"
        case .gpt4t:
            return "gpt-4-1106-preview"
        case .orphind:
            return "phind/phind-codellama-34b-v2"
        case .orcodellama:
            return "meta-llama/codellama-34b-instruct"
        case .ormistral:
            return "open-orca/mistral-7b-openorca"
        case .ormythomax:
            return "gryphe/mythomax-l2-13b"
        case .orpalm:
            return "google/palm-2-chat-bison"
        case .orpalmcode:
            return "google/palm-2-codechat-bison"
        case .orzephyr:
            return "huggingfaceh4/zephyr-7b-beta"
        case .orgpt3:
            return "openai/gpt-3.5-turbo-1106"
        case .orgpt4t:
            return "openai/gpt-4-1106-preview"
        case .orhermes:
            return "nousresearch/nous-hermes-llama2-13b"
        case .ortoppy:
            return "undi95/toppy-m-7b"
        case .claude2:
            return "claude-2"
        case .claudeinstant:
            return "claude-instant"
        }
    }

    var maxTokens: Int {
        switch self {
        case .gpt3t, .gpt3t_16, .gpt4, .gpt4t, .orphind, .orcodellama, .ormistral, .ormythomax, .orzephyr, .orgpt3, .orgpt4t, .orhermes, .ortoppy, .claude2, .claudeinstant:
            return 3800
        case .orpalm, .orpalmcode:
            return 2000
        }
    }

    static let openAIModels: [Model] = [.gpt3t, .gpt3t_16, .gpt4, .gpt4t]
    static let openRouterModels: [Model] = [.orphind, .orcodellama, .ormistral, .ormythomax, .orpalm, .orpalmcode, .orzephyr, .orgpt3, .orgpt4t, .orhermes, .ortoppy]
    static let customModels: [Model] = openAIModels + [.claude2, .claudeinstant]
}
