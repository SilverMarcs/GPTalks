//
//  NonStreamResponse.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/11/2024.
//

import Foundation

struct NonStreamResponse {
    let content: String?
    let toolCalls: [ChatToolCall]?
    let inputTokens: Int
    let outputTokens: Int
}
