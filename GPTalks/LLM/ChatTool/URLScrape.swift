//
//  URLScrape.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import Foundation
import OpenAI
import Reeeed

struct URLScrape {
    struct URLList: Codable {
        let url_list: [String]
    }
    
    static func getContent(from arguments: String) async -> ToolData {
        var totalContent: String = ""
        let urls = URLScrape.getURLs(from: arguments)
        for url in urls {
            let content = await URLScrape.retrieveWebContent(from: url)
            totalContent += content
        }
        return .init(string: totalContent)
    }
    
    private static func getURLs(from jsonString: String) -> [URL] {
        let jsonData = jsonString.data(using: .utf8)!
        let urlList = try! JSONDecoder().decode(URLList.self, from: jsonData)
        
        // Convert strings to URL objects
        let urls = urlList.url_list.compactMap { URL(string: $0) }
        return urls
    }
    
    static func retrieveWebContent(from url: URL) async -> String {
        var final: String = "An error occurred while fetching the content."
        
        do {
            DispatchQueue.main.async { Reeeed.warmup() }
            
            let extracted = try await Reeeed.fetchAndExtractContent(fromURL: url)
            
            let url = extracted.baseURL.relativeString
            let title = extracted.title ?? "Title not available"
            let content = stripHTML(from: extracted.extracted.content ?? "")
            
            final = [title, url, content].joined(separator: "\n")
        } catch {
            print(error.localizedDescription)
        }
        
        return String(final.prefix(ToolConfigDefaults.shared.maxContentLength))
    }
    
    
    private static func stripHTML(from input: String) -> String {
        guard let data = input.data(using: .utf8) else {
            return input
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        } else {
            return input
        }
    }
    
    static var openai: ChatQuery.ChatCompletionToolParam {
        return .init(function:
                .init(name: "urlScrape",
                      description: """
                                    You can open a URL directly if one is provided by the user. 
                                    If you need more context or info, you may also call this with URLs returned by the googleSearch function.
                                    Use this if the context from a previous googleSearch is not sufficient to answer the user's question and you need more info
                                    for a more in-depth response.
                                    """,
                      parameters:
                        .init(type: .object,
                              properties: [
                                "url_list":
                                    .init(type: .array, description: "The array of URLs of the websites to scrape", items: .init(type: .string), maxItems: 5)
                                ]
                             )
                     )
        )
    }
}
