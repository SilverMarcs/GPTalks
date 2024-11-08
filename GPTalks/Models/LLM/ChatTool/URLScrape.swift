//
//  URLScrape.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import Foundation
import OpenAI
import GoogleGenerativeAI

struct URLScrape: ToolProtocol {
    static let toolName = "urlScrape"
    static let displayName: String = "URL Scrape"
    static let icon: String = "network"
    
    struct URLList: Codable {
        let url_list: [String]
    }
    
    struct ArticleResponse: Codable {
        let error: Int
        let message: String
        let data: ArticleData
    }

    struct ArticleData: Codable {
        let url: String
        let title: String
        let content: String
    }
    
    static func process(arguments: String) async throws -> ToolData {
        var totalContent: String = ""
        let urls = try URLScrape.getURLs(from: arguments)
        for url in urls {
            let content = try await URLScrape.retrieveWebContent(from: url)
            totalContent += content
        }
        return .init(string: totalContent)
    }
    
    private static func getURLs(from jsonString: String) throws -> [URL] {
        let jsonData = jsonString.data(using: .utf8)!
        let urlList = try JSONDecoder().decode(URLList.self, from: jsonData)
        
        // Convert strings to URL objects
        let urls = urlList.url_list.compactMap { URL(string: $0) }
        return urls
    }
    
    static func retrieveWebContent(from url: URL) async throws -> String {
        let apiKey = ToolConfigDefaults.shared.rapidApiKey
        guard !apiKey.isEmpty else {
            throw RuntimeError("RapidAPI key is missing")
        }
        
        let encodedURL = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let apiURL = URL(string: "https://article-extractor2.p.rapidapi.com/article/proxy/parse?url=\(encodedURL)")!
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.addValue("article-extractor2.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.addValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(ArticleResponse.self, from: data)
        
        let strippedContent = stripHTML(from: response.data.content)
        let content = strippedContent.isEmpty ? "Tool was unable to scrape URL" : strippedContent
        
        return ["URL: \(url.absoluteString)", "Title: \(response.data.title)", content].joined(separator: "\n")
    }

    static func stripHTML(from html: String) -> String {
        guard let data = html.data(using: .utf8) else { return "" }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return ""
        }
        
        return attributedString.string
    }
    
    static let description: String = """
        You can open a URL directly if one is provided by the user.
        If you need more context or info, you may also call this with URLs returned by the googleSearch function.
        But never try to use made up google search link with this tool, it is not a search engine. 
        Use this if the context from a previous googleSearch is not sufficient to answer the user's question and you need more info
        for a more in-depth response.
        """
    
    static let jsonSchemaString = """
    ```
    {
      "name": "\(toolName)",
      "description": "\(description)",
      "parameters": {
        "type": "object",
        "properties": {
          "url_list": {
            "type": "array",
            "description": "The array of URLs of the websites to scrape",
            "items": {
              "type": "string"
            }
          }
        }
      }
    }
    ```
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
                                "url_list":
                                    .init(
                                        type: .array,
                                        description: "The array of URLs of the websites to scrape",
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
                    "url_list": .init(
                        type: .array,
                        description: "The array of URLs of the websites to scrape",
                        items: .init(type: .string)
                    )
                ],
                requiredParameters: ["url_list"]
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
                    "url_list": [
                        "type": "array",
                        "description": "The array of URLs of the websites to scrape",
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
