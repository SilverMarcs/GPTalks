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
    func toOpenAI() -> ChatQuery.ChatCompletionMessageParam {
        if self.dataFiles.isEmpty {
            return ChatQuery.ChatCompletionMessageParam(
                role: self.role.toOpenAIRole(),
                content: self.content
            )!
        } else {
            var visionContent: [ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content.VisionContent] = []
            
            for dataFile in self.dataFiles {
                if dataFile.fileType.conforms(to: .image) {
                    visionContent.append(.init(chatCompletionContentPartImageParam: .init(imageUrl: .init(url: dataFile.data, detail: .auto))))
                } else if dataFile.fileType.conforms(to: .pdf) {
                    if let url = FileHelper.createTemporaryURL(for: dataFile) {
                        let contents = readPDF(from: url)
                        visionContent.append(.init(chatCompletionContentPartTextParam: .init(text: "PDF File contents: \n\(contents)\n Respond to the user based on their query.")))
                    }
                } else if dataFile.fileType.conforms(to: .text) {
                    if let textContent = String(data: dataFile.data, encoding: .utf8) {
                        visionContent.append(.init(chatCompletionContentPartTextParam: .init(text: "Text File contents: \n\(textContent)\n Respond to the user based on their query.")))
                    }
                }
            }
            
            visionContent.append(.init(chatCompletionContentPartTextParam: .init(text: self.content)))

            return ChatQuery.ChatCompletionMessageParam(
                role: self.role.toOpenAIRole(),
                content: visionContent
            )!
        }
    }

    func toGoogle() -> ModelContent {
        var parts: [ModelContent.Part] = [.text(content)]
        
        for dataFile in self.dataFiles {
            if dataFile.fileType.conforms(to: .text) {
                parts.insert(.text(String(data: dataFile.data, encoding: .utf8) ?? ""), at: 0)
            } else {
                parts.insert(.data(mimetype: dataFile.mimeType, dataFile.data), at: 0)
            }
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
            } else if dataFile.fileType.conforms(to: .pdf) {
                if let url = FileHelper.createTemporaryURL(for: dataFile) {
                    let contents = readPDF(from: url)
                    contentObjects.append(.text("PDF File contents: \n\(contents)\n Respond to the user based on their query."))
                }
            } else if dataFile.fileType.conforms(to: .text) {
                if let textContent = String(data: dataFile.data, encoding: .utf8) {
                    contentObjects.append(.text("Text File contents: \n\(textContent)\n Respond to the user based on their query."))
                }
            }
        }
        
        contentObjects.append(.text(self.content))
        
        let finalContent: MessageParameter.Message = .init(
            role: self.role.toClaudeRole(),
            content: .list(contentObjects)
        )
        
        return finalContent
    }
    
    func toVertex() -> Any {
        var contentObjects: [[String: Any]] = []
        
        for dataFile in dataFiles {
            if dataFile.fileType.conforms(to: .image) {
                let imageSource: [String: Any] = [
                    "type": "base64",
                    "media_type": dataFile.mimeType,
                    "data": dataFile.data.base64EncodedString()
                ]
                let imageContent: [String: Any] = [
                    "type": "image",
                    "source": imageSource
                ]
                contentObjects.append(imageContent)
            } else if dataFile.fileType.conforms(to: .pdf) {
                if let url = FileHelper.createTemporaryURL(for: dataFile) {
                    let contents = readPDF(from: url)
                    contentObjects.append([
                        "type": "text",
                        "text": "PDF File contents: \n\(contents)\n Respond to the user based on their query."
                    ])
                }
            } else if dataFile.fileType.conforms(to: .text) {
                if let textContent = String(data: dataFile.data, encoding: .utf8) {
                    contentObjects.append([
                        "type": "text",
                        "text": "Text File contents: \n\(textContent)\n Respond to the user based on their query."
                    ])
                }
            }
        }
        
        // Add the main conversation content
        contentObjects.append([
            "type": "text",
            "text": self.content
        ])
        
        // Construct the final dictionary
        let finalContent: [String: Any] = [
            "role": self.role.rawValue,
            "content": contentObjects
        ]
        
        return finalContent
    }

}
