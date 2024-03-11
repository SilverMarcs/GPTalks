//
//  GoogleSearch.swift
//  GPTalks
//
//  Created by Zabir Raihan on 11/03/2024.
//

import Foundation

struct SearchResult: Decodable {
    let items: [SearchItem]
}

struct SearchItem: Decodable {
    let title: String
    let link: String
    let snippet: String
}

class GoogleSearchService {
    private let apiKey = AppConfiguration.shared.googleApiKey
    private let searchEngineId = AppConfiguration.shared.googleSearchEngineId
    
    func performSearch(query: String) async throws -> String {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/customsearch/v1?q=\(encodedQuery)&key=\(apiKey)&cx=\(searchEngineId)"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Decoding the JSON data into a dictionary
        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let items = jsonResult["items"] as? [[String: Any]] {
            // Building a string representation of the search results
            let searchResultsString = items.map { item -> String in
                let title = item["title"] as? String ?? "No title"
                let link = item["link"] as? String ?? "No link"
                let snippet = item["snippet"] as? String ?? "No snippet"
                return "Title: \(title)\nLink: \(link)\nSnippet: \(snippet)\n"
            }.joined(separator: "\n")
            
            return searchResultsString
        } else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse search results"])
        }
    }
}
