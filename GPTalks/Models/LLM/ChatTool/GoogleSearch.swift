//
//  GoogleSearch.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import Foundation
import OpenAI
import GoogleGenerativeAI
import SwiftAnthropic

struct GoogleSearch: ToolProtocol {
    static let toolName = "googleSearch"
    static let displayName: String = "Google Search"
    static let icon: String = "safari" 
    
    static func performSearch(query: String) async throws -> ToolData {
        let apiKey = ToolConfigDefaults.shared.googleApiKey
        let googleSearchEngineId = ToolConfigDefaults.shared.googleSearchEngineId
        
        guard !apiKey.isEmpty, !googleSearchEngineId.isEmpty else {
            throw RuntimeError("API key and/or search engine ID not set")
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/customsearch/v1?q=\(encodedQuery)&key=\(apiKey)&cx=\(googleSearchEngineId)"
        
        guard let url = URL(string: urlString) else {
            throw RuntimeError("Failed to create URL from string: \(urlString)")
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)

        // Check for HTTP error and extract error message
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let error = jsonResult["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw RuntimeError("Search API error: \(message)")
                }
                
                if let items = jsonResult["items"] as? [[String: Any]] {
                    let searchResultsString = items.map { item -> String in
                        let title = item["title"] as? String ?? "No title"
                        let link = item["link"] as? String ?? "No link"
                        let snippet = item["snippet"] as? String ?? "No snippet"
                        return "Title: \(title)\nLink: \(link)\nSnippet: \(snippet)\n"
                    }.joined(separator: "\n")
                    
                    return ToolData(string: searchResultsString)
                }
            }
        } catch {
            throw RuntimeError("Failed to parse search results: \(error.localizedDescription)")
        }
        
        throw RuntimeError("Failed to parse search results")
    }
    
    static func process(arguments: String) async throws -> ToolData {
        let query = try getQuery(from: arguments)
        
        return try await performSearch(query: query)
    }
    
    private static func getQuery(from jsonString: String) throws -> String {
        let jsonData = jsonString.data(using: .utf8)!
        let query = try JSONDecoder().decode(Query.self, from: jsonData)
        
        return query.query
    }
    
    struct Query: Codable {
        let query: String
    }
    
    struct SearchResult: Decodable {
        let items: [SearchItem]
    }
    
    struct SearchItem: Decodable {
        let title: String
        let link: String
        let snippet: String
    }
    
    static let description = """
        Use this when
        - User is asking about current events or something that requires real-time information (weather, sports scores, etc.)
        - User is asking about some term you are totally unfamiliar with (it might be new)
        - Always prioritize your pre-existing knowledge before wanting to call this tool
        Do not call this tool unless you are absolutely certain that the information you have is outdated or incorrect or you have no knowledge about the topic. Try confirming with the user first before automatically calling this tool.        
        """
    
    static let jsonSchemaString = """
    ```json
    {
      "name": "\(toolName)",
      "description": "\(description)",
      "parameters": {
        "type": "object",
        "properties": {
          "query": {
            "type": "string",
            "description": "The search query to search google with"
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
                            .init(type: .object,
                                  properties: ["query":
                                        .init(type: .string,
                                              description: "The search query to search google with")]
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
                    "query": .init(
                        type: .string,
                        description: "The search query to search google with"
                    )
                ],
                requiredParameters: ["query"]
            )
        ])
    }
    
    static var anthropic: MessageParameter.Tool {
        .init(
            name: toolName,
            description: description,
            inputSchema: .init(
                type: .object,
                properties: [
                    "query": .init(type: .string, description: "The search query to search google with"),
                ],
                required: ["query"])
        )
    }
}
