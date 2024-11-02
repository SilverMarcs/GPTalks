//
//  StringExtensions.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import Foundation
import SwiftUI

extension String {
    func copyToPasteboard() {
#if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
#else
        UIPasteboard.general.string = self
#endif
    }
    
    static let bottomID = "bottomID"
    static let topID = "topID"
    static let testPrompt = "Respond with just the word Test"
    
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
    
    func absoluteURL() -> URL? {
        // Get the URL for the Documents directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // Append the relative path to the Documents directory URL
        let fileURL = documentsDirectory.appendingPathComponent(self)
        
        return fileURL
    }
    
    func truncateText() -> String {
        let maxCharacters = 20
        
        if self.count > maxCharacters {
            let prefixLength = maxCharacters / 2 - 1
            let suffixLength = maxCharacters / 2 - 1
            let prefix = self.prefix(prefixLength)
            let suffix = self.suffix(suffixLength)
            return "\(prefix)...\(suffix)"
        } else {
            return self
        }
    }
    
    func prettyPrintJSON() -> String {
        guard let data = self.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              var prettyString = String(data: prettyData, encoding: .utf8) else {
            return self
        }
        
        // Unescape forward slashes
        prettyString = prettyString.replacingOccurrences(of: "\\/", with: "/")
        
        return prettyString
    }
    
    func extractRelevantText(matching searchText: String) -> String? {
        guard self.range(of: searchText, options: .caseInsensitive) != nil else {
            return nil
        }
        
        let lines = self.components(separatedBy: .newlines)
        guard let matchedLineIndex = lines.firstIndex(where: { $0.range(of: searchText, options: .caseInsensitive) != nil }) else {
            return nil
        }
        
        let startIndex = max(0, matchedLineIndex - 5)
        let endIndex = min(lines.count - 1, matchedLineIndex + 5)
        
        let relevantLines = Array(lines[startIndex...endIndex])
        return relevantLines.joined(separator: "\n")
    }
}
