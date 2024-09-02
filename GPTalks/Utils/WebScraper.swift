//
//  WebScraper.swift
//  GPTalks
//
//  Created by Zabir Raihan on 01/09/2024.
//

import Foundation
import Reeeed

struct WebScraper {
    static func retrieveWebContent(from url: URL) async -> String {
        var final: String = "An error occurred while fetching the content."
        
        do {
            DispatchQueue.main.async { Reeeed.warmup() }
            
            let extracted = try await Reeeed.fetchAndExtractContent(fromURL: url)
            
            let url = extracted.baseURL.relativeString
            let title = extracted.title ?? "Title not available"
            let content = stripHTML(from: extracted.extracted.content ?? "")
            
            final = [title, url, content].joined(separator: "\n\n")
        } catch {
            print(error.localizedDescription)
        }
        
        return String(final.prefix(5000))
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
}
