//
//  WebScrapeService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/02/2024.
//

import Foundation
import SwiftSoup
import Reeeed


func stripHTML(from input: String) -> String {
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


func retrieveWebContent(from urlStr: String) async throws -> String {
    
    var extractedHTML: String = ""
    
    if let url = URL(string: urlStr) {
        DispatchQueue.main.async { Reeeed.warmup() }

        let content = try await Reeeed.fetchAndExtractContent(fromURL: url)
    
        let extracted = content.extracted.content ?? ""
        
        extractedHTML = stripHTML(from: extracted)

    }
    
    return extractedHTML

}

// Modify fetchAndParseHTML to include a completion handler that returns an array of String or an error
func fetchAndParseHTML(from urlString: String, completion: @escaping (Result<[String], Error>) -> Void) {
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
            completion(.failure(error ?? NSError(domain: "NetworkError", code: 0, userInfo: nil)))
            return
        }
        
        if let htmlContent = String(data: data, encoding: .utf8) {
            // Call parseHTML with the completion handler
            parseHTML(htmlContent, completion: completion)
        }
    }

    task.resume()
}

func fetchAndParseHTMLAsync(from urlString: String) async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
        fetchAndParseHTML(from: urlString) { result in
            switch result {
            case .success(let pTexts):
                // Join the strings and slice to the first 5000 characters
                let joinedText = pTexts.joined(separator: " ").prefix(5000)
                continuation.resume(returning: String(joinedText))
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}

// Modify parseHTML to use a completion handler
func parseHTML(_ html: String, completion: @escaping (Result<[String], Error>) -> Void) {
    do {
        let doc: Document = try SwiftSoup.parse(html)
        
        var articleTexts = [String]()
        
        // Extract text from relevant HTML tags
        let tagsToExtract = ["p", "span", "article", "h1", "h2", "h3", "h4", "h5", "h6", "blockquote", "li", "td", "th"]
        for tag in tagsToExtract {
            let elements: Elements = try doc.select(tag)
            for element in elements.array() {
                let text = try element.text()
                articleTexts.append(text)
            }
        }
        
        completion(.success(articleTexts))
    } catch Exception.Error(let type, let message) {
        print("Error: \(type) \(message)")
        completion(.failure(NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "\(type) \(message)"])))
    } catch {
        completion(.failure(error))
    }
}
