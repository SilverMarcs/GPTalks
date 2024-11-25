//
//  HighlightedTextViews.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/11/24.
//

import SwiftUI

struct HighlightedText: View {
    let text: String
    let highlightedText: String
    var selectable: Bool = true
    
    var body: some View {
        if selectable {
            comprised
                .textSelection(.enabled)
        } else {
            comprised
                .textSelection(.disabled)
        }
    }
    
    @ViewBuilder
    var comprised: some View {
        if !highlightedText.isEmpty {
            AttributedText(
                text: text,
                highlightText: highlightedText,
                parseMarkdown: false
            )
        } else {
            Text(text)
        }
    }
}

struct AttributedText: View {
    @ObservedObject private var config = AppConfig.shared
    let attributedString: NSAttributedString

    init(text: String, highlightText: String, parseMarkdown: Bool) {
        let mutableString: NSMutableAttributedString
        if parseMarkdown {
            mutableString = AttributedText.parseMarkdown(text)
        } else {
            mutableString = NSMutableAttributedString(string: text)
        }
        AttributedText.applyHighlighting(to: mutableString, highlightText: highlightText)
        self.attributedString = mutableString
    }

    private static func parseMarkdown(_ text: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        let scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = nil

        let baseSize = AppConfig.shared.fontSize
        let defaultFont = PlatformFont.systemFont(ofSize: baseSize)
        let monoFont = PlatformFont.monospacedSystemFont(ofSize: baseSize - 1, weight: .regular)
        let boldFont = PlatformFont.boldSystemFont(ofSize: baseSize)

        while !scanner.isAtEnd {
            if scanner.scanString("```") != nil {
                // Code block
                // Skip the language signifier if present
                let _ = scanner.scanUpToCharacters(from: .newlines)
                let _ = scanner.scanCharacters(from: .newlines)
                
                if let codeContent = scanner.scanUpToString("```") {
                    if scanner.scanString("```") != nil {
                        let codeAttributed = NSAttributedString(string: codeContent, attributes: [.font: monoFont])
                        attributedString.append(codeAttributed)
                    } else {
                        // No closing ``` found
                        attributedString.append(NSAttributedString(string: "```\(codeContent)", attributes: [.font: defaultFont]))
                    }
                } else {
                    // No closing ``` found
                    let remainingText = scanner.string[scanner.currentIndex...]
                    attributedString.append(NSAttributedString(string: String(remainingText), attributes: [.font: defaultFont]))
                    break
                }
            } else if scanner.scanString("`") != nil {
                // Inline code
                if let codeContent = scanner.scanUpToString("`") {
                    if scanner.scanString("`") != nil {
                        let codeAttributed = NSAttributedString(string: codeContent, attributes: [.font: monoFont])
                        attributedString.append(codeAttributed)
                    } else {
                        // No closing ` found
                        attributedString.append(NSAttributedString(string: "`\(codeContent)", attributes: [.font: defaultFont]))
                    }
                } else {
                    // No closing ` found
                    attributedString.append(NSAttributedString(string: "`", attributes: [.font: defaultFont]))
                }
            } else if scanner.scanString("**") != nil {
                // Bold text
                if let boldContent = scanner.scanUpToString("**") {
                    if scanner.scanString("**") != nil {
                        let boldAttributed = NSAttributedString(string: boldContent, attributes: [.font: boldFont])
                        attributedString.append(boldAttributed)
                    } else {
                        // No closing ** found
                        attributedString.append(NSAttributedString(string: "**\(boldContent)", attributes: [.font: defaultFont]))
                    }
                } else {
                    // No closing ** found
                    attributedString.append(NSAttributedString(string: "**", attributes: [.font: defaultFont]))
                }
            } else if scanner.scanString("#") != nil {
                // Heading
                var headingLevel = 1
                while scanner.scanString("#") != nil {
                    headingLevel += 1
                }
                let _ = scanner.scanCharacters(from: .whitespaces) // Skip whitespace
                if let headingContent = scanner.scanUpToCharacters(from: .newlines) {
                    let headingSize: CGFloat
                    switch headingLevel {
                    case 1:
                        headingSize = baseSize * 2.0
                    case 2:
                        headingSize = baseSize * 1.7
                    case 3:
                        headingSize = baseSize * 1.4
                    case 4:
                        headingSize = baseSize * 1.1
                    default:
                        headingSize = baseSize
                    }
                    let headingFont = PlatformFont.systemFont(ofSize: headingSize, weight: .bold)
                    let headingAttributed = NSAttributedString(string: headingContent, attributes: [.font: headingFont])
                    attributedString.append(headingAttributed)
                }
                // add newline after heading
                attributedString.append(NSAttributedString(string: "\n"))
            } else {
                // Regular text
                if let textContent = scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "`*#")) {
                    let textAttributed = NSAttributedString(string: textContent, attributes: [.font: defaultFont])
                    attributedString.append(textAttributed)
                } else {
                    // Handle special characters not part of markdown syntax
                    if let char = scanner.scanCharacter() {
                        attributedString.append(NSAttributedString(string: String(char), attributes: [.font: defaultFont]))
                    }
                }
            }
        }
        return attributedString
    }

    private static func applyHighlighting(to attributedString: NSMutableAttributedString, highlightText: String) {
        let nsString = attributedString.string as NSString
        let stringLength = nsString.length
        var searchRange = NSRange(location: 0, length: stringLength)
        
        while searchRange.location < stringLength {
            let foundRange = nsString.range(
                of: highlightText,
                options: .caseInsensitive,
                range: searchRange
            )
            
            if foundRange.location == NSNotFound {
                break
            }
            
            // Highlighting takes priority - save existing attributes
            let existingAttributes = attributedString.attributes(at: foundRange.location, effectiveRange: nil)
            
            // Apply highlight attributes while preserving existing ones
            var newAttributes = existingAttributes
            newAttributes[.backgroundColor] = PlatformColor.yellow
            newAttributes[.foregroundColor] = PlatformColor.black
            
            attributedString.setAttributes(newAttributes, range: foundRange)
            
            searchRange.location = foundRange.location + foundRange.length
            searchRange.length = stringLength - searchRange.location
        }
    }

    var body: some View {
        Text(AttributedString(attributedString))
            .lineSpacing(2)
            .font(.system(size: config.fontSize))
    }
}
