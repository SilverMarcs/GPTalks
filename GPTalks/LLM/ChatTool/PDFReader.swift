//
//  PDFReader.swift
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

struct PDFReader: ToolProtocol {
    static let toolName = "pdfReader"
    static let displayName: String = "PDF Reader"
    static let icon: String = "doc.text"
    
    struct PDFArgs: Codable {
        let conversationID: String
        let pdfNames: [String]
    }
    
    static func process(arguments: String) async throws -> ToolData {
        let args = try PDFReader.getPDFIds(from: arguments)
        
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
            
            for name in args.pdfNames {
                if let typedData = conversation.dataFiles.first(where: { $0.fileName == name }) {
                    guard typedData.fileType == .pdf else {
                        throw RuntimeError("File is not a PDF: \(name)")
                    }
                    let pdfContent = readPDF(from: typedData.data)
                    totalContent += pdfContent + "\n"
                }
            }
            
            return .init(string: totalContent)
        } else {
            throw RuntimeError("No conversation found with the given ID")
        }
    }

    private static func getPDFIds(from jsonString: String) throws -> PDFArgs {
        let jsonData = jsonString.data(using: .utf8)!
        let pdfArgs = try JSONDecoder().decode(PDFArgs.self, from: jsonData)
        return pdfArgs
    }
    
    private static func readPDF(from data: Data) -> String {
        guard let document = PDFDocument(data: data) else {
            return "Unable to load PDF from data"
        }
        
        return document.string ?? "Unable to read PDF content"
    }
    
    static let tokenCount = countTokensFromText(description)
    
    static let description: String = """
        You can open and access contents of PDF files. Just respond with a list of PDF file names with .pdf extension.
        Only use this tool when user explicitly provides PDF files.
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
                                "pdfNames":
                                    .init(
                                        type: .array,
                                        description: "The array of PDF file names with .pdf extension to access",
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
                    "pdfNames": Schema(
                        type: .array,
                        description: "The array of PDF file names with .pdf extension to access",
                        items: Schema(type: .string)
                    )
                ],
                requiredParameters: ["conversationID", "pdfNames"]
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
                    "pdfNames": [
                        "type": "array",
                        "description": "The array of PDF file names with .pdf extension to access",
                        "items": [
                            "type": "string"
                        ],
                        "maxItems": 5
                    ]
                ],
                "required": ["conversationID", "pdfNames"]
            ]
        ]
    }
}
