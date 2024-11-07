//
//  ContentHelper.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/09/2024.
//


struct ContentHelper {
    
    static func processDataFiles(_ dataFiles: [TypedData], conversationContent: String) -> [ProcessedContent] {
        var processedContents: [ProcessedContent] = []
        
        for dataFile in dataFiles {
            if dataFile.fileType.conforms(to: .image) {
                let imageContent = ProcessedContent.image(
                    mimeType: dataFile.mimeType,
                    base64Data: dataFile.data.base64EncodedString()
                )
                processedContents.append(imageContent)
            }
            else if dataFile.fileType.conforms(to: .text) {
                if let textContent = String(data: dataFile.data, encoding: .utf8) {
                    processedContents.append(.text("Text File contents: \n\(textContent)\n Respond to the user based on their query."))
                }
            }
        }
        
        // Always append the conversation content at the end
        processedContents.append(.text(conversationContent))
        
        return processedContents
    }
}

enum ProcessedContent {
    case image(mimeType: String, base64Data: String)
    case text(String)
    
    // Additional helper methods to convert to different formats could go here
}
