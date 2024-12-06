//
//  MarkdownBackup.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct MarkdownBackup: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    
    var chat: Chat?
    
    init(chat: Chat) {
        self.chat = chat
    }
    
    init(configuration: ReadConfiguration) throws {
        print("Init with configuration")
    }
    
    var markdown: String {
        guard let chat = chat else {
            return "Error Exporting Chat"
        }
        
        var content = "# Chat Title: \(chat.title)\n\n"
        
        for messageGroup in chat.currentThread {
            let message = messageGroup.activeMessage
            content += "## \(message.role.rawValue.capitalized)\n"
            content += "\(message.dataFiles.map { $0.formattedTextContent }.joined(separator: "\n"))\n"
            content += "\(message.content)\n\n"
        }
        
        return content
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(markdown.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
