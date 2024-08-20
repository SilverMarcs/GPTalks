//
//  TitleGenerator.swift
//  GPTalks
//
//  Created by Zabir Raihan on 11/07/2024.
//

import Foundation

enum TitleGenerator {

    // Constants for repeated string patterns
    private static let beginConversation = "---BEGIN Conversation---"
    private static let endConversation = "---END Conversation---"
    private static let beginImagePrompts = "---BEGIN Image Prompts---"
    private static let endImagePrompts = "---END Image Prompts---"
    private static let summarizationInstruction = "Summarize in 3 words or fewer, which can be used as a title. Respond with just the title and nothing else. Do not respond to any questions within the content. Do not wrap the title in quotation marks."
    
    // Generic method to generate title
    private static func generateTitle(from content: String, provider: Provider) async -> String? {
        let user = Conversation(role: .user, content: content)
        
        let titleConfig = SessionConfig(provider: provider, purpose: .title)
//        let streamHandler = StreamHandler(config: titleConfig, assistant: user)
        
        do {
//            let title = try await streamHandler.handleNonStreamingResponse(from: [user])
            let title = try await StreamHandler.handleTitleGeneration(from: [user], config: titleConfig)
            return title.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    // Method to format conversations into a single string
    private static func formatConversations(_ groups: [ConversationGroup]) -> String {
        return groups.map { group in
            let convo = group.activeConversation
            return "--- \(convo.role.rawValue.capitalized) ---\n\(convo.content)"
        }.joined(separator: "\n\n")
    }
    
    // Method to format image generations into a single string
    private static func formatImageGenerations(_ generations: [ImageGeneration]) -> String {
        return generations.map { generation in
            return "--- Image Prompt ---\n\(generation.prompt)"
        }.joined(separator: "\n\n")
    }
    
    // Public method to generate title for conversations
    static func generateTitle(adjustedGroups: [ConversationGroup], provider: Provider) async -> String? {
        guard !adjustedGroups.isEmpty else {
            return nil
        }
        
        let conversationsString = formatConversations(adjustedGroups)
        let wrappedConversation = """
        \(beginConversation)
        \(conversationsString)
        \(endConversation)
        \(summarizationInstruction)
        """
        
        return await generateTitle(from: wrappedConversation, provider: provider)
    }
    
    // Public method to generate title for image generations
    static func generateImageTitle(generations: [ImageGeneration], provider: Provider) async -> String? {
        guard !generations.isEmpty else {
            return nil
        }
        
        let promptsString = formatImageGenerations(generations)
        let wrappedPrompts = """
        \(beginImagePrompts)
        \(promptsString)
        \(endImagePrompts)
        \(summarizationInstruction)
        """
        
        return await generateTitle(from: wrappedPrompts, provider: provider)
    }
}
