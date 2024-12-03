//
//  StreamResponse.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import Foundation

enum StreamResponse {
    case content(String)
    case toolCalls([ChatToolCall])
    case totalTokens(TokenUsage)
}

struct TokenUsage {
    let inputTokens: Int
    let outputTokens: Int
}
