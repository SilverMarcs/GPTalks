//
//  GoogleSearch.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import Foundation
import SwiftOpenAI
import GoogleGenerativeAI

struct GoogleSearch {
    static func performSearch(query: String) async throws -> ToolData {
        let apiKey = ToolConfigDefaults.shared.googleApiKey
        let googleSearchEngineId = ToolConfigDefaults.shared.googleSearchEngineId
        
        // if the private values are not set, throw an error
        guard !apiKey.isEmpty, !googleSearchEngineId.isEmpty else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "API key and/or search engine ID not set"])
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/customsearch/v1?q=\(encodedQuery)&key=\(apiKey)&cx=\(googleSearchEngineId)"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Decoding the JSON data into a dictionary
        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let items = jsonResult["items"] as? [[String: Any]] {
            
            let topItems = items.prefix(ToolConfigDefaults.shared.gSearchCount)
            
            // Building a string representation of the search results
            let searchResultsString = topItems.map { item -> String in
                let title = item["title"] as? String ?? "No title"
                let link = item["link"] as? String ?? "No link"
                let snippet = item["snippet"] as? String ?? "No snippet"
                return "Title: \(title)\nLink: \(link)\nSnippet: \(snippet)\n"
            }.joined(separator: "\n")
            
            return .init(string: searchResultsString)
        } else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse search results"])
        }
    }
    
    static func getResults(from arguments: String) async throws -> ToolData {
        let query = getQuery(from: arguments)
        
        return try await performSearch(query: query)
    }
    
    private static func getQuery(from jsonString: String) -> String {
        let jsonData = jsonString.data(using: .utf8)!
        let query = try! JSONDecoder().decode(Query.self, from: jsonData)
        
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
    
    static let tokenCount = countTokensFromText(description)
    
    static let description = """
        Use this when
        - User is asking about current events or something that requires real-time information (weather, sports scores, etc.)
        - User is asking about some term you are totally unfamiliar with (it might be new)
        - Usually prioritize your pre-existing knowledge before wanting to call this tool
        """
    
    static var openai: ChatCompletionParameters.Tool {
        .init(function:
                .init(
                    name: "googleSearch",
                    strict: false,
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
                name: "googleSearch",
                description: description,
                parameters: [
                    "query": Schema(
                        type: .string,
                        description: "The search query to search google with"
                    )
                ],
                requiredParameters: ["query"]
            )
        ])
    }

    static var vertex: [String: Any] {
        [
            "name": "googleSearch",
            "description": description,
            "input_schema": [
                "type": "object",
                "properties": [
                    "query": [
                        "type": "string",
                        "description": "The search query to search google with"
                    ]
                ],
                "required": ["query"]
            ]
        ]
    }

}
