//
//  WebScrapeService.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/02/2024.
//

import Foundation
import SwiftSoup

@MainActor
func getSummaryText(inputText: String) async -> String? {
    let preProcessed = inputText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

    if preProcessed.contains("summarize") || preProcessed.contains("summarise") {
        let urlString = findURL(in: preProcessed)!
        
        do {
            let pTexts = try await fetchAndParseHTMLAsync(from: urlString)
            return pTexts.joined()
//                print(allText)
        } catch {
            print("Failed to fetch or parse HTML: \(error.localizedDescription)")
        }
    }
    
    return nil
}

func findURL(in input: String) -> String? {
// Split the input string into words or components separated by whitespace
let components = input.components(separatedBy: .whitespacesAndNewlines)

// Iterate through each component to check if it can be initialized as a URL with a scheme
for component in components {
    if let url = URL(string: component), url.scheme != nil {
        // Found a component that can be initialized as a URL with a scheme
        // Return the URL as a String
        return component
    }
}

// No component could be initialized as a URL with a scheme
return nil
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

func fetchAndParseHTMLAsync(from urlString: String) async throws -> [String] {
    return try await withCheckedThrowingContinuation { continuation in
        fetchAndParseHTML(from: urlString) { result in
            switch result {
            case .success(let pTexts):
                continuation.resume(returning: pTexts)
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
    let pTags: Elements = try doc.select("p")
    
    var pTexts = [String]()
    for pTag in pTags.array() {
        let pText = try pTag.text()
        pTexts.append(pText)
    }
    
    completion(.success(pTexts))
} catch Exception.Error(let type, let message) {
    print("Error: \(type) \(message)")
    completion(.failure(NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "\(type) \(message)"])))
} catch {
    completion(.failure(error))
}
}
