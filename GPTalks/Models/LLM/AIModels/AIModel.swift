//
//  AIModel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/11/2024.
//

import Foundation
import SwiftData

@Model
class AIModel: Hashable, Identifiable {
    var id: UUID = UUID()
    var code: String
    var name: String
    var isEnabled: Bool
    var testResult: Bool?
    var type: ModelType
    
    init(code: String, name: String, type: ModelType, isEnabled: Bool = true) {
        self.code = code
        self.name = name
        self.type = type
        self.isEnabled = isEnabled
    }
}

extension AIModel {
    static func getOpenaiModels() -> [AIModel] {
        return [
            .init(code: "gpt-4o-mini", name: "GPT-4om", type: .chat),
            .init(code: "gpt-4o", name: "GPT-4o", type: .chat),
            .init(code: "chatgpt-4o-latest", name: "ChatGPT-4o-Latest", type: .chat),
            .init(code: "o1-mini", name: "o1-mini", type: .chat),
            .init(code: "o1-preview", name: "o1-preview", type: .chat),
            .init(code: "dall-e-2", name: "DALL-E-2", type: .image),
            .init(code: "dall-e-3", name: "DALL-E-3", type: .image),
            .init(code: "whisper-1", name: "Whisper-1", type: .stt),
        ]
    }
    
    static func getAnthropicModels() -> [AIModel] {
        return [
            .init(code: "claude-3-5-haiku-latest", name: "Claude-3.5H", type: .chat),
            .init(code: "claude-3-5-sonnet-latest", name: "Claude-3.5S", type: .chat),
        ]
    }
    
    static func getGoogleModels() -> [AIModel] {
        return [
            .init(code: "gemini-1.5-flash-latest", name: "Gemini-1.5F", type: .chat),
            .init(code: "gemini-1.5-flash-8b-latest", name: "Gemini-1.5F-8B", type: .chat),
            .init(code: "gemini-1.5-pro-latest", name: "Gemini-1.5P", type: .chat),
            .init(code: "gemini-2.0-flash-latest", name: "Gemini-2F", type: .chat),
        ]
    }
    
    static func getVertexModels() -> [AIModel] {
        return [
            .init(code: "claude-3-5-haiku@20241022", name: "Claude-3.5H", type: .chat),
            .init(code: "claude-3-5-sonnet@20240620", name: "Claude-3.5S", type: .chat),
        ]
    }
    
    static func getXaiModels() -> [AIModel] {
        return [
            .init(code: "grok-2-1212", name: "Grok-2", type: .chat),
            .init(code: "grok-2-vision-121", name: "Grok-2V", type: .chat),
        ]
    }
    
    static func getOpenrouterModels() -> [AIModel] {
        return [
            .init(code: "openai/gpt-4o-mini", name: "GPT-4om", type: .chat),
            .init(code: "openai/gpt-4o", name: "GPT-4o", type: .chat),
            .init(code: "anthropic/claude-3.5-sonnet", name: "Claude-3.5S", type: .chat),
            .init(code: "anthropic/claude-3-5-haiku", name: "Claude-3.5H", type: .chat),
            .init(code: "meta-llama/llama-3.1-8b-instruct", name: "Llama-3.1-8B", type: .chat),
        ]
    }
    
    static func getGroqModels() -> [AIModel] {
        return [
            .init(code: "gemma2-9b-it", name: "Gemma-2-9B", type: .chat),
            .init(code: "gemma-7b-it", name: "Gemma-7B", type: .chat),
            .init(code: "llama3-groq-70b-8192-tool-use-preview", name: "LLaMA-3-Groq-70B", type: .chat),
            .init(code: "llama3-groq-8b-8192-tool-use-preview", name: "LLaMA-3-Groq-8B", type: .chat),
            .init(code: "llama-3.1-70b-versatile", name: "LLaMA-3.1-70B-Versatile", type: .chat),
            .init(code: "llama-3.1-8b-instant", name: "LLaMA-3.1-8B-Instant", type: .chat),
            .init(code: "llama-3.2-1b-preview", name: "LLaMA-3.2-1B", type: .chat),
            .init(code: "llama-3.2-3b-preview", name: "LLaMA-3.2-3B", type: .chat),
            .init(code: "llama-3.2-11b-vision-preview", name: "LLaMA-3.2-11B-Vision", type: .chat),
            .init(code: "llama-3.2-90b-vision-preview", name: "LLaMA-3.2-90B-Vision", type: .chat),
            .init(code: "llama-guard-3-8b", name: "LLaMA-Guard-3-8B", type: .chat),
            .init(code: "llama3-70b-8192", name: "LLaMA-3-70B", type: .chat),
            .init(code: "llama3-8b-8192", name: "LLaMA-3-8B", type: .chat),
            .init(code: "mixtral-8x7b-32768", name: "Mixtral-8x7B", type: .chat),
            .init(code: "whisper-large-v3", name: "Whisper-Large-V3", type: .stt),
            .init(code: "whisper-large-v3-turbo", name: "Whisper-Large-V3-Turbo", type: .stt),
        ]
    }
    
    static func getMistralModels() -> [AIModel] {
        return [
            .init(code: "ministral-3b-latest", name: "Ministral-3B", type: .chat),
            .init(code: "ministral-8b-latest", name: "Ministral-8B", type: .chat),
            .init(code: "open-mistral-nemo", name: "Open-Mistral-Nemo", type: .chat),
            .init(code: "mistral-small-latest", name: "Mistral-Small", type: .chat),
            .init(code: "mistral-medium-latest", name: "Mistral-Medium", type: .chat),
            .init(code: "mistral-large-latest", name: "Mistral-Large", type: .chat),
            .init(code: "codestral-latest", name: "Codestral", type: .chat),
            .init(code: "pixtral-12b-2409", name: "Pixtral-12B-2409", type: .chat),
        ]
    }
    
    static func getPerplexityModels() -> [AIModel] {
        return [
            .init(code: "llama-3.1-sonar-small-128k-online", name: "Llama-3.1-sonar-small-online", type: .chat),
            .init(code: "llama-3.1-sonar-large-128k-online", name: "Llama-3.1-sonar-large-online", type: .chat),
            .init(code: "llama-3.1-sonar-huge-128k-online", name: "Llama-3.1-sonar-huge-online", type: .chat),
            .init(code: "llama-3.1-sonar-small-128k-chat", name: "Llama-3.1-sonar-small-chat", type: .chat),
            .init(code: "llama-3.1-sonar-large-128k-chat", name: "Llama-3.1-sonar-large-chat", type: .chat),
            .init(code: "llama-3.1-sonar-small-128k-chat", name: "Llama-3.1-sonar-small-chat", type: .chat),
            .init(code: "llama-3.1-sonar-large-128k-chat", name: "Llama-3.1-sonar-large-chat", type: .chat),
            .init(code: "llama-3.1-8b-instruct", name: "Llama-3.1-8B", type: .chat),
            .init(code: "llama-3.1-70b-instruct", name: "Llama-3.1-70B", type: .chat),
        ]
    }
    
    static func getTogetherModels() -> [AIModel] {
        return [
            .init(code: "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo", name: "Meta-Llama-3.1-8B-Instruct-Turbo", type: .chat),
            .init(code: "meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo", name: "Meta-Llama-3.1-70B-Instruct-Turbo", type: .chat),
            .init(code: "meta-llama/Meta-Llama-3.1-405B-Instruct-Turbo", name: "Meta-Llama-3.1-405B-Instruct-Turbo", type: .chat),
            .init(code: "meta-llama/Llama-3.2-3B-Instruct-Turbo", name: "Llama-3.2-3B-Instruct-Turbo", type: .chat),
            .init(code: "meta-llama/Llama-3.2-11B-Vision-Instruct-Turbo", name: "Llama-3.2-11B-Vision-Instruct-Turbo", type: .chat),
            .init(code: "meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo", name: "Llama-3.2-90B-Vision-Instruct-Turbo", type: .chat),
            .init(code: "microsoft/WizardLM-2-8x22B", name: "WizardLM-2-8x22B", type: .chat),
            .init(code: "google/gemma-2-27b-it", name: "Gemma-2-27B", type: .chat),
            .init(code: "google/gemma-2-9b-it", name: "Gemma-2-9B", type: .chat),
            .init(code: "google/gemma-2b-it", name: "Gemma-2B", type: .chat),
            .init(code: "deepseek-ai/deepseek-lIm-67b-chat", name: "Deepseek-LIM-67B-Chat", type: .chat),
            .init(code: "Gryphe/MythoMax-L2-13b", name: "MythoMax-L2-13B", type: .chat),
            .init(code: "mistralai/Mistral-7B-Instruct-v0.3", name: "Mistral-7B-Instruct-V0.3", type: .chat),
            .init(code: "mistralai/Mixtral-8x7B-Instruct-v0.3", name: "Mixtral-8x7B-Instruct-V0.3", type: .chat),
            .init(code: "mistralai/Mixtral-8x22B-Instruct-V0.1", name: "Mixtral-8x22B-Instruct-V0.1", type: .chat),
            .init(code: "NousResearch/Nous-Hermes-2-Mixtral-8x7B-DPO", name: "Nous-Hermes-2-Mixtral-8x7B-DPO", type: .chat),
            .init(code: "Qwen/Qwen2.5-7B-Instruct-Turbo", name: "Qwen2.5-7B-Instruct-Turbo", type: .chat),
            .init(code: "Qwen/Qwen2.5-72B-Instruct-Turbo", name: "Qwen2.5-72B-Instruct-Turbo", type: .chat),
            .init(code: "Qwen/Qwen2.5-Coder-32B-Instruct", name: "Qwen2.5-Coder-32B-Instruct", type: .chat),
            .init(code: "black-forest-labs/FLUX.1-schnell-Free", name: "FLUX.1-Schnell-Free", type: .image),
            .init(code: "black-forest-labs/FLUX.1-schnell", name: "FLUX.1-Schnell", type: .image),
            .init(code: "black-forest-labs/FLUX.1.1-pro", name: "FLUX.1.1-Pro", type: .image),
            .init(code: "black-forest-labs/FLUX.1-pro", name: "FLUX.1-Pro", type: .image),
            .init(code: "stabilityai/stable-diffusion-xl-base-1.0", name: "Stable-Diffusion-XL-Base-1.0", type: .image),
        ]
    }
    
    static func getLocalModels() -> [AIModel] {
        return [
            .init(code: "dummy-chat-model", name: "Dummy-Chat", type: .chat),
            .init(code: "dummy-image-model", name: "Dummy-Image", type: .image),
            .init(code: "dummy-stt-model", name: "Dummy-STT", type: .stt),
        ]
    }
}
