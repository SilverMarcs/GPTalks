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
        var contentObjects: [MessageParameter.Message.Content.ContentObject] = []
        
        for dataFile in dataFiles {
            if dataFile.fileType.conforms(to: .image) {
                let imageSource = MessageParameter.Message.Content.ImageSource(
                    type: .base64,
                    mediaType: .init(rawValue: dataFile.mimeType) ?? .jpeg,
                    data: dataFile.data.base64EncodedString()
                )
                contentObjects.append(.image(imageSource))
            } else {
                // TODO: do RAG conversion here
                contentObjects.append(.text("\(dataFile.fileExtension.uppercased()) files are not supported yet. Notify the user."))
            }
        }
        
        contentObjects.append(.text(self.content))
        
        let finalContent: MessageParameter.Message = .init(
            role: self.role.toClaudeRole(),
            content: .list(contentObjects)
        )
        
        return finalContent
    }
}
