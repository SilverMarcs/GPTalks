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
    
    // return only the first 10000 characters
    return String(extractedHTML.prefix(2500))
//    return extractedHTML

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

//func extractURLs(from jsonString: String, forKey key: String) -> [String]? {
//    guard let jsonData = jsonString.data(using: .utf8) else {
//        print("Error: Could not convert string to UTF-8 data.")
//        return nil
//    }
//
//    do {
//        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
//           let urls = jsonObject[key] as? [String] {
//            return urls
//        } else {
//            print("Error: JSON does not contain a valid '\(key)' key or it's not an array of strings.")
//            return nil
//        }
//    } catch {
//        print("Error parsing JSON: \(error)")
//        return nil
//    }
//}


func extractURLs(from jsonString: String, forKey key: String) -> [String]? {
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Error: Could not convert string to UTF-8 data.")
        return nil
    }

    do {
        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
            var urls: [String] = []
            // Check if the value for the key is an array or a single string and handle accordingly
            if let urlArray = jsonObject[key] as? [String] {
                urls = urlArray
            } else if let url = jsonObject[key] as? String {
                urls = [url] // Treat a single string as an array with one element
            }
            
            // Ensure we have at least one URL
            guard !urls.isEmpty else {
                print("Error: JSON does not contain valid '\(key)' or it's not in the expected format.")
                return nil
            }
            
            return urls
        } else {
            print("Error: JSON does not contain a valid '\(key)' key or it's not an array of strings.")
            return nil
        }
    } catch {
        print("Error parsing JSON: \(error)")
        return nil
    }
}
