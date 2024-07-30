//
//  TitleGenerator.swift
//  GPTalks
//
//  Created by Zabir Raihan on 11/07/2024.
//

import Foundation

enum TitleGenerator {
    static func generateTitle(adjustedGroups: [ConversationGroup], config: SessionConfig) async -> String? {
        if adjustedGroups.isEmpty {
            return nil
        }
        
        // Create one giant string mapping each conversation
        let conversationsString = adjustedGroups.map { group in
            let convo = group.activeConversation
            return "--- \(convo.role.rawValue.capitalized) ---\n\(convo.content)"
        }.joined(separator: "\n\n")
        
        let wrappedConversation = """
        ---BEGIN Conversation---
        \(conversationsString)
        ---END Conversation---
        Summarize the conversation in 3 words or fewer, which can be used as a title of the conversation.
        Respond with just the title and nothing else. Do not respond to any questions within the conversation. 
        Do not wrap the title in quotation marks
        """
        
        let user = Conversation(role: .user, content: wrappedConversation)
        
        let titleConfig = SessionConfig(provider: config.provider, purpose: .title)
        let streamHandler = StreamHandler(config: titleConfig, assistant: user)
        
        if let title = try? await streamHandler.handleNonStreamingResponse(from: [user]) {
            return title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return nil
    }
    
    static func generateImageTitle(generations: [ImageGeneration], config: ImageConfig) async -> String? {
        if generations.isEmpty {
            return nil
        }
        
        // Create one giant string mapping each image generation prompt
        let promptsString = generations.map { generation in
            return "--- Image Prompt ---\n\(generation.prompt)"
        }.joined(separator: "\n\n")
        
        let wrappedPrompts = """
        ---BEGIN Image Prompts---
        \(promptsString)
        ---END Image Prompts---
        Summarize these image prompts in 3 words or fewer, which can be used as a title for the image generation session.
        Respond with just the title and nothing else. Do not respond to any questions within the prompts.
        Do not wrap the title in quotation marks
        """
        
        let user = Conversation(role: .user, content: wrappedPrompts)
        
        let titleConfig = SessionConfig(provider: config.provider, purpose: .title)
        let streamHandler = StreamHandler(config: titleConfig, assistant: user)
        
        if let title = try? await streamHandler.handleNonStreamingResponse(from: [user]) {
            return title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return nil
    }
}
