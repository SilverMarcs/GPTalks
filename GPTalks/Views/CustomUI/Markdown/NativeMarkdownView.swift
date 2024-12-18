//
//  NativeMarkdownView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct NativeMarkdownView: View {
    @ObservedObject private var config = AppConfig.shared
    var attributed: AttributedString

    var body: some View {
        Text(attributed)
    }
    
    init(text: String, highlightText: String) {
        self.attributed = NativeMarkdownView.parseMarkdown(text)
        if !highlightText.isEmpty {
            self.attributed = NativeMarkdownView.applyHighlighting(to: self.attributed, highlightText: highlightText)
        }
    }

    private static func parseMarkdown(_ text: String) -> AttributedString {
        var attributed = AttributedString()
        
        let scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = nil

        let baseSize = AppConfig.shared.fontSize
        
        while !scanner.isAtEnd {
            if scanner.scanString("```") != nil {
                let _ = scanner.scanUpToCharacters(from: .newlines) ?? ""
                let _ = scanner.scanCharacters(from: .newlines)
                
                if let codeContent = scanner.scanUpToString("```") {
                    if scanner.scanString("```") != nil {
//                        if codeContent.last == "\n" {
//                            codeContent.removeLast()
//                        }
                        var codeAttribute = AttributedString(codeContent)
                        codeAttribute.font = .monospacedSystemFont(ofSize: baseSize - 1, weight: .regular)
                        attributed.append(codeAttribute)
                    } else {
                        var fallback = AttributedString("```\(codeContent)")
                        fallback.font = .systemFont(ofSize: baseSize)
                        attributed.append(fallback)
                    }
                }
            } else if scanner.scanString("`") != nil {
                if let codeContent = scanner.scanUpToString("`") {
                    if scanner.scanString("`") != nil {
                        var inlineCode = AttributedString(codeContent)
                        inlineCode.font = .monospacedSystemFont(ofSize: baseSize - 1, weight: .regular)
                        inlineCode.backgroundColor = .secondarySystemFill
                        attributed.append(inlineCode)
                    } else {
                        var fallback = AttributedString("`\(codeContent)")
                        fallback.font = .systemFont(ofSize: baseSize)
                        attributed.append(fallback)
                    }
                }
            } else if scanner.scanString("**") != nil {
                if let boldContent = scanner.scanUpToString("**") {
                    if scanner.scanString("**") != nil {
                        var bold = AttributedString(boldContent)
                        bold.font = .boldSystemFont(ofSize: baseSize)
                        attributed.append(bold)
                    } else {
                        var fallback = AttributedString("**\(boldContent)")
                        fallback.font = .systemFont(ofSize: baseSize)
                        attributed.append(fallback)
                    }
                }
            } else if scanner.scanString("#") != nil {
                var headingLevel = 1
                while scanner.scanString("#") != nil {
                    headingLevel += 1
                }
                let _ = scanner.scanCharacters(from: .whitespaces)
                if let headingContent = scanner.scanUpToCharacters(from: .newlines) {
                    let headingSize: CGFloat = baseSize * (2.0 - (0.3 * CGFloat(headingLevel - 1)))
                    var heading = AttributedString(headingContent)
                    heading.font = .systemFont(ofSize: headingSize, weight: .bold)
                    attributed.append(heading)
                }
            } else {
                if let textContent = scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "`*#")) {
                    var text = AttributedString(textContent)
                    text.font = .systemFont(ofSize: baseSize)
                    attributed.append(text)
                } else if let char = scanner.scanCharacter() {
                    var text = AttributedString(String(char))
                    text.font = .systemFont(ofSize: baseSize)
                    attributed.append(text)
                }
            }
        }

        return attributed
    }

    private static func applyHighlighting(to attributedString: AttributedString, highlightText: String) -> AttributedString {
        guard !highlightText.isEmpty else { return attributedString }
        
        var attributed = attributedString
        let lowercasedHighlight = highlightText.lowercased()
        
        var searchRange = attributed.startIndex..<attributed.endIndex
        
        while let foundRange = attributed[searchRange].range(of: lowercasedHighlight, options: .caseInsensitive) {
            // Apply highlighting to the found range
            attributed[foundRange].backgroundColor = .yellow
            attributed[foundRange].foregroundColor = .black
            
            // Update the search range to start after the current foundRange
            if foundRange.upperBound >= searchRange.upperBound {
                break
            }
            searchRange = foundRange.upperBound..<searchRange.upperBound
        }
        
        return attributed
    }
}



#Preview {
    List {
        NativeMarkdownView(text: "Hello, **world**!", highlightText: "")
    }
}
