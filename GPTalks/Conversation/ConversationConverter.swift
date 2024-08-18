//
//  ConversationConverter.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/08/2024.
//

import Foundation
import OpenAI
import GoogleGenerativeAI
import SwiftAnthropic

extension Conversation {
//    func toOpenAI() -> ChatQuery.ChatCompletionMessageParam {
//        if self.imagePaths.isEmpty {
//            return ChatQuery.ChatCompletionMessageParam(
//                role: self.role.toOpenAIRole(),
//                content: self.content
//            )!
//        } else {
//            let visionContent: [ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content.VisionContent] = [
//                .chatCompletionContentPartTextParam(.init(text: self.content))
//            ] + self.imagePaths.map { imagePath in
//                if let imageData = loadImageData(from: imagePath) {
//                    return .chatCompletionContentPartImageParam(
//                        .init(imageUrl: .init(
//                            url: imageData,
//                            detail: .auto
//                        ))
//                    )
//                } else {
//                    return .chatCompletionContentPartTextParam(.init(text: "Failed to load image. Notify the user."))
//                }
//            }
//
//            return ChatQuery.ChatCompletionMessageParam(
//                role: self.role.toOpenAIRole(),
//                content: visionContent
//            )!
//        }
//    }
    
    func toOpenAI() -> ChatQuery.ChatCompletionMessageParam {
        return ChatQuery.ChatCompletionMessageParam(
            role: self.role.toOpenAIRole(),
            content: self.content
        )!
    }

    func toGoogle() -> ModelContent {
        // TODO: add video support
        var parts: [ModelContent.Part] = [.text(content)]
        
        for dataFile in self.dataFiles {
            parts.insert(.data(mimetype: dataFile.mimeType, dataFile.data), at: 0)
        }
        
        return ModelContent(
            role: role.toGoogleRole(),
            parts: parts
        )
    }
    
    func toClaude() -> MessageParameter.Message {
        // Initialize an array to hold ContentObject instances
        var contentObjects: [MessageParameter.Message.Content.ContentObject] = []
        
        // Add the text content
        contentObjects.append(.text(self.content))
        
        // Iterate over each image path, load the image, convert to base64, and append to contentObjects
//        for imagePath in imagePaths {
//            if let imageData = loadImageData(from: imagePath) {
//                let base64String = imageData.base64EncodedString()
//                let imageSource = MessageParameter.Message.Content.ImageSource(
//                    type: .base64,
//                    mediaType: .jpeg,
//                    data: base64String
//                )
//                contentObjects.append(.image(imageSource))
//            } else {
//                print("Could not load image from path: \(imagePath)")
//            }
//        }
        
        // Create the visionContent with the collected contentObjects
        let visionContent: MessageParameter.Message = .init(
            role: self.role.toClaudeRole(),
            content: .list(contentObjects)
        )
        
        return visionContent
    }
}
