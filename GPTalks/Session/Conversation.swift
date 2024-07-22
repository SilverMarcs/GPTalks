//
//  Conversation.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import Foundation

import Foundation
import SwiftData
import OpenAI
import GoogleGenerativeAI
import SwiftAnthropic

@Model
final class Conversation: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Conversation(role: role, content: content)
        copy.model = model
        copy.imagePaths = imagePaths
        
        return copy
    }
    
    var id: UUID = UUID()
    var date: Date = Date()
    
    var group: ConversationGroup?
    var model: AIModel?
    
    var content: String
    var imagePaths: [String] = []
    var role: ConversationRole
    
    @Attribute(.ephemeral)
    var isReplying: Bool = false
    
    init(role: ConversationRole, content: String, imagePaths: [String] = []) {
        self.role = role
        self.content = content
        self.imagePaths = imagePaths
    }
    
    init(role: ConversationRole, content: String, model: AIModel, imagePaths: [String] = []) {
        self.role = role
        self.content = content
        self.model = model
        self.imagePaths = imagePaths
    }
    
    init(role: ConversationRole, content: String, group: ConversationGroup, imagePaths: [String] = []) {
        self.role = role
        self.content = content
        self.group = group
        self.imagePaths = imagePaths
    }
    
    init(role: ConversationRole, content: String, model: AIModel, isReplying: Bool = false) {
        self.role = role
        self.content = content
        self.group = group
        self.model = model
        self.isReplying = isReplying
    }
    
    func toOpenAI() -> ChatQuery.ChatCompletionMessageParam {
        if self.imagePaths.isEmpty {
            return ChatQuery.ChatCompletionMessageParam(
                role: self.role.toOpenAIRole(),
                content: self.content
            )!
        } else {
            let visionContent: [ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content.VisionContent] = [
                .chatCompletionContentPartTextParam(.init(text: self.content))
            ] + self.imagePaths.map { imagePath in
                if let imageData = loadImageData(from: imagePath) {
                    return .chatCompletionContentPartImageParam(
                        .init(imageUrl: .init(
                            url: imageData,
                            detail: .auto
                        ))
                    )
                } else {
                    return .chatCompletionContentPartTextParam(.init(text: "Failed to load image. Notify the user."))
                }
            }
            
            return ChatQuery.ChatCompletionMessageParam(
                role: self.role.toOpenAIRole(),
                content: visionContent
            )!
        }
    }

    func toGoogle() -> ModelContent {
        // This supports sending a lot of data types
        
        if self.imagePaths.isEmpty {
            return ModelContent(
                role: role.toGoogleRole(),
                parts: [.text(content)]
            )
        } else {
            let visionContent: [ModelContent.Part] = [
                .text(content)
            ] + self.imagePaths.map { imagePath in
                if let imageData = loadImageData(from: imagePath) {
                    return .jpeg(imageData)
                } else {
                    return .text("Failed to load image. Notify the user.")
                }
            }
            
            return ModelContent(
                role: role.toGoogleRole(),
                parts: visionContent
            )
        }
    }
    
    func toClaude() -> MessageParameter.Message {
        // Initialize an array to hold ContentObject instances
        var contentObjects: [MessageParameter.Message.Content.ContentObject] = []
        
        // Add the text content
        contentObjects.append(.text(self.content))
        
        // Iterate over each image path, load the image, convert to base64, and append to contentObjects
        for imagePath in imagePaths {
            if let imageData = loadImageData(from: imagePath) {
                let base64String = imageData.base64EncodedString()
                let imageSource = MessageParameter.Message.Content.ImageSource(
                    type: .base64,
                    mediaType: .jpeg,
                    data: base64String
                )
                contentObjects.append(.image(imageSource))
            } else {
                print("Could not load image from path: \(imagePath)")
            }
        }
        
        // Create the visionContent with the collected contentObjects
        let visionContent: MessageParameter.Message = .init(
            role: self.role.toClaudeRole(),
            content: .list(contentObjects)
        )
        
        return visionContent
    }
    
    func countTokens() -> Int {
        let textToken = tokenCount(text: content)
        // TODO: Count image tokens
        return textToken
    }
    
    func deleteSelf() {
        group?.deleteConversation(self)
    }
}
