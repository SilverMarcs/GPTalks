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

//enum ConversationRole: Codable {
//    case user
//    case assistant(AssistantType)
//    case system
//    case tool
//
//    enum AssistantType: String, Codable {
//        case regular
//        case tool
//    }


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
        case .user:
            return "user"
        case .assistant:
            return "model"
        case .system:
            return "user"
        case .tool:
            return "tool"
        }
    }
    
    func toClaudeRole() -> MessageParameter.Message.Role {
        switch self {
        case .user:
            return .user
        case .assistant:
            return .assistant
        case .system, .tool:
            return .assistant
        }
    }
}
