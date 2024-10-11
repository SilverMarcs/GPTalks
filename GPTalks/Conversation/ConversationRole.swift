//
//  ConversationRole.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/07/2024.
//

import Foundation
import OpenAI
import GoogleGenerativeAI
import SwiftAnthropic

enum ConversationRole: String, Codable {
    case user
    case assistant
    case system
    case tool
    
    func toOpenAIRole() -> ChatQuery.ChatCompletionMessageParam.Role {
        switch self {
        case .user:
            return .user
        case .assistant:
            return .assistant
        case .system:
            return .system
        case .tool:
            return .tool
        }
    }
    
    func toGoogleRole() -> String {
        switch self {
        case .user, .system, .tool:
            return "user"
        case .assistant:
            return "model"
        }
    }
    
    func toClaudeRole() -> MessageParameter.Message.Role {
        switch self {
        case .user:
            return .user
        case .assistant, .system, .tool:
            return .assistant
        }
    }
    
    func toVertexRole() -> String {
        switch self {
        case .user, .tool, .system:
            return "user"
        case .assistant:
            return "assistant"
        }
    }
}
