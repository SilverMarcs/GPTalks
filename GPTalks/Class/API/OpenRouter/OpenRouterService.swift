//
//  OpenAIService.swift
//  ChatGPT
//
//  Created by Zabir Raihan on 2023/3/3.
//

import SwiftUI

class OpenRouterService: BaseChatService {
    
    override var provider: AIProvider {
        return .openRouter
    }
    
    override var baseURL: String {
        return "https://openrouter.ai/api"
    }
    
    override var path: String {
        return "/v1/chat/completions"
    }
    
    override var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(configuration.key)",
            "HTTP-Referer": "https://github.com/SilverMarcs"
        ]
    }
    
}
