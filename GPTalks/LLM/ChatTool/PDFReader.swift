//
//  PDFReader.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/10/2024.
//

import Foundation
import SwiftData
import SwiftOpenAI
import GoogleGenerativeAI
import PDFKit


struct PDFReader {
    struct PDFArgs: Codable {
        let conversationID: String
        let fileNames: [String]
    }
    
    static func getContent(from arguments: String) async throws -> ToolData {
        var totalContent: String = ""
        let args = try PDFReader.getFileIds(from: arguments)
        
        let modelContext = DatabaseService.shared.modelContext
        let uuid = UUID(uuidString: args.conversationID)!
        
        let fetchDescriptor = FetchDescriptor<Conversation>(
            predicate: #Predicate { conversation in
                conversation.id == uuid
            }
        )
        
        let conversations = try modelContext.fetch(fetchDescriptor)
        
        if let conversation = conversations.first {
            for name in args.fileNames {
                if let typedData = conversation.dataFiles.first(where: { $0.fileName == name }) {
                    let pdfContent = readPDF(from: typedData.data)
                    totalContent += pdfContent.prefix(ToolConfigDefaults.shared.pdfMaxContentLength) + "\n"
                }
            }
            
            return .init(string: totalContent)
        } else {
            throw RuntimeError("No conversation found with the given ID")
        }
    }

    private static func getFileIds(from jsonString: String) throws -> PDFArgs {
        let jsonData = jsonString.data(using: .utf8)!
        let urlList = try JSONDecoder().decode(PDFArgs.self, from: jsonData)
        return urlList
    }
    
    private static func readPDF(from data: Data) -> String {
        guard let document = PDFDocument(data: data) else {
            return "Unable to load PDF from data"
        }
        
        let pageCount = document.pageCount
        var content = ""
        
        for i in 0 ..< pageCount {
            guard let page = document.page(at: i) else { continue }
            guard let pageContent = page.string else { continue }
            content += pageContent
        }
        
        return content
    }
    
    static let tokenCount = countTokensFromText(description)
    
    static let description: String = """
        You can open and access contents of pdf files. Just respond with a list of file names without file extensions
        """
    
    static var openai: ChatCompletionParameters.Tool {
        .init(function:
                .init(
                    name: "pdfReader",
                    strict: false,
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
                                        description: "The array of pdf file ids to access",
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
                name: "pdfReader",
                description: description,
                parameters: [
                    "conversationID": Schema(
                        type: .string,
                        description: "The conversation ID"
                    ),
                    "fileNames": Schema(
                        type: .array,
                        description: "The array of pdf file ids to access",
                        items: Schema(type: .string)
                    )
                ],
                requiredParameters: ["conversationID", "fileNames"]
            )
        ])
    }
    
    static var vertex: [String: Any] {
         [
            "name": "pdfReader",
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
                        "description": "The array of pdf file ids to access",
                        "items": [
                            "type": "string"
                        ],
                        "maxItems": 5
                    ]
                ],
                "required": ["url_list"]
            ]
        ]
    }
}
