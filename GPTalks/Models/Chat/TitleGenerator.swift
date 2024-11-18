//
//  TitleGenerator.swift
//  GPTalks
//
//  Created by Zabir Raihan on 11/07/2024.
//

import Foundation

enum TitleGenerator {
    // Constants for repeated string patterns
    private static let beginMessage = "---BEGIN Message---"
    private static let endMessage = "---END Message---"
    private static let beginImagePrompts = "---BEGIN Image Prompts---"
    private static let endImagePrompts = "---END Image Prompts---"
    private static let summarizationInstruction = "Summarize in 3 words or fewer, which can be used as a title. Respond with just the title and nothing else. Do not respond to any questions within the content. Do not wrap the title in quotation marks."
    
    // Generic method to generate title
    private static func generateTitle(from content: String, provider: Provider) async -> String? {
        let user = Message(role: .user, content: content)
        
        let titleConfig = ChatConfig(provider: provider, purpose: .title)
        
        do {
            let serviceType = titleConfig.provider.type.getService()
            let response = try await serviceType.nonStreamingResponse(from: [user], config: titleConfig)
            let title = response.content ?? "Error generating title"
            
            return title.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    // Method to format conversations into a single string
    private static func formatMessages(_ messages: [Message]) -> String {
        return messages.map { message in
            var toolResponse: String = ""
            
            let toolCalls = message.toolCalls.map { toolCall in
                "Called tool: \(toolCall.tool.rawValue)"
            }.joined(separator: "\n")
            
            let dataFiles = message.dataFiles.map { dataFile in
                "Data file: \(dataFile.fileName)"
            }.joined(separator: "\n")
            
            if let response = message.toolResponse {
                toolResponse = "Tool response: \(response)"
            }
            
            return "--- \(message.role.rawValue.capitalized) ---\n\(message.content)\n\(toolCalls)\n\(dataFiles)\n\(toolResponse)"
        }.joined(separator: "\n\n")
    }
    
    // Method to format image generations into a single string
    private static func formatGenerations(_ generations: [Generation]) -> String {
        return generations.map { generation in
            return "--- Image Prompt ---\n\(generation.config.prompt)"
        }.joined(separator: "\n\n")
    }
    
    // Public method to generate title for conversations
    public static func generateTitle(messages: [Message], provider: Provider) async -> String? {
        guard !messages.isEmpty else {
            return nil
        }
        
        let conversationsString = formatMessages(messages.dropLast()) // drop last bc dont wanna send empty assistant message
        let wrappedMessage = """
        \(beginMessage)
        \(conversationsString)
        \(endMessage)
        \(summarizationInstruction)
        """
        
        return await generateTitle(from: wrappedMessage, provider: provider)
    }
    
    // Public method to generate title for image generations
    public static func generateImageTitle(generations: [Generation], provider: Provider) async -> String? {
        guard !generations.isEmpty else {
            return nil
        }
        
        let promptsString = formatGenerations(generations)
        let wrappedPrompts = """
        \(beginImagePrompts)
        \(promptsString)
        \(endImagePrompts)
        \(summarizationInstruction)
        """
        
        return await generateTitle(from: wrappedPrompts, provider: provider)
    }
}
