//
//  FileReader.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/10/2024.
//

import Foundation
import SwiftData
import OpenAI
import GoogleGenerativeAI
import PDFKit
import UniformTypeIdentifiers

struct FileReader: ToolProtocol {
    static let toolName = "fileReader"
    static let displayName: String = "File Reader"
    static let icon: String = "doc.text"
    
    struct FileArgs: Codable {
        let conversationID: String
        let fileNames: [String]
    }
    
    static func process(arguments: String) async throws -> ToolData {
        let args = try FileReader.getFileIds(from: arguments)
        
        let modelContext = DatabaseService.shared.modelContext
        let uuid = UUID(uuidString: args.conversationID)!
        
        let fetchDescriptor = FetchDescriptor<Conversation>(
            predicate: #Predicate { conversation in
                conversation.id == uuid
            }
        )
        
        let conversations = try modelContext.fetch(fetchDescriptor)
        
        if let conversation = conversations.first {
            var totalContent: String = ""
            
            for name in args.fileNames {
                if let typedData = conversation.dataFiles.first(where: { $0.fileName == name }) {
                    let fileContent: String
                    if isPDF(data: typedData.data) {
                        fileContent = readPDF(from: typedData.data)
                    } else {
                        fileContent = readTextFile(from: typedData.data)
                    }
                    totalContent += fileContent + "\n"
                }
            }
            
            return .init(string: totalContent)
        } else {
            throw RuntimeError("No conversation found with the given ID")
        }
    }

    private static func getFileIds(from jsonString: String) throws -> FileArgs {
        let jsonData = jsonString.data(using: .utf8)!
        let fileArgs = try JSONDecoder().decode(FileArgs.self, from: jsonData)
        return fileArgs
    }
    
    private static func isPDF(data: Data) -> Bool {
        let pdfHeader: [UInt8] = [0x25, 0x50, 0x44, 0x46] // PDF header bytes
        guard data.count >= pdfHeader.count else { return false }
        
        for i in 0..<pdfHeader.count {
            if data[i] != pdfHeader[i] {
                return false
            }
        }
        
        return true
    }
    
    private static func readPDF(from data: Data) -> String {
        guard let document = PDFDocument(data: data) else {
            return "Unable to load PDF from data"
        }
        
        return document.string ?? "Unable to read PDF content"
    }
    
    private static func readTextFile(from data: Data) -> String {
        if let text = String(data: data, encoding: .utf8) {
            return text
        } else {
            return "Unable to read file content"
        }
    }
    
    static let tokenCount = countTokensFromText(description)
    
    static let description: String = """
        You can open and access contents of both PDF files and text-based files. Just respond with a list of file names with file extensions.
        Only use this tool when user explicitly provide files
        """
    
    static var openai: ChatQuery.ChatCompletionToolParam {
        .init(function:
                .init(
                    name: toolName,
                    description: description,
                    parameters:
                        .init(
                            type: .object,
                            properties: [
                                "conversationID":
                                        .init(
                                            type: .string,
                                            description: "The conversation ID"
                                        ),
                                "fileNames":
                                    .init(
                                        type: .array,
                                        description: "The array of file names with extension to access",
                                        items: .init(type: .string)
                                    )
                            ]
                        )
                )
        )
    }
    
    static var google: Tool {
        Tool(functionDeclarations: [
            FunctionDeclaration(
                name: toolName,
                description: description,
                parameters: [
                    "conversationID": Schema(
                        type: .string,
                        description: "The conversation ID"
                    ),
                    "fileNames": Schema(
                        type: .array,
                        description: "The array of file names with extension to access",
                        items: Schema(type: .string)
                    )
                ],
                requiredParameters: ["conversationID", "fileNames"]
            )
        ])
    }
    
    static var vertex: [String: Any] {
         [
            "name": toolName,
            "description": description,
            "input_schema": [
                "type": "object",
                "properties": [
                    "conversationID": [
                        "type": "string",
                        "description": "The conversation ID"
                    ],
                    "fileNames": [
                        "type": "array",
                        "description": "The array of file names with extension to access",
                        "items": [
                            "type": "string"
                        ],
                        "maxItems": 5
                    ]
                ],
                "required": ["conversationID", "fileNames"]
            ]
        ]
    }
}
