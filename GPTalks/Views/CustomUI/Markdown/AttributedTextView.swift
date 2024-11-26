//
//  AttributedTextView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct AttributedTextView: View {
    @ObservedObject private var config = AppConfig.shared
    var contentItems: [ContentItem]

    init(text: String, highlightText: String, parseMarkdown: Bool = false) {
        if parseMarkdown {
            self.contentItems = AttributedTextView.parseMarkdown(text)
        } else {
            self.contentItems = [.text(NSAttributedString(string: text))]
        }
        AttributedTextView.applyHighlighting(to: &self.contentItems, highlightText: highlightText)
    }

    private static func parseMarkdown(_ text: String) -> [ContentItem] {
        var contentItems: [ContentItem] = []
        let scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = nil

        let baseSize = AppConfig.shared.fontSize
        let defaultFont = PlatformFont.systemFont(ofSize: baseSize)
        let monoFont = PlatformFont.monospacedSystemFont(ofSize: baseSize - 1, weight: .regular)
        let boldFont = PlatformFont.boldSystemFont(ofSize: baseSize)

        var currentAttributedString = NSMutableAttributedString()

        func appendCurrentAttributedString() {
            if currentAttributedString.length > 0 {
                contentItems.append(.text(currentAttributedString))
                currentAttributedString = NSMutableAttributedString()
            }
        }

        while !scanner.isAtEnd {
            if scanner.scanString("```") != nil {
                // Code block
                appendCurrentAttributedString()
                
                let language = scanner.scanUpToCharacters(from: .newlines) ?? ""
                let _ = scanner.scanCharacters(from: .newlines)
                
                if var codeContent = scanner.scanUpToString("```") {
                    if scanner.scanString("```") != nil {
                        // remove trailing newline if any
                        if codeContent.last == "\n" {
                            codeContent.removeLast()
                        }
                        let codeAttributedString = NSAttributedString(string: codeContent, attributes: [.font: monoFont])
                        contentItems.append(.codeBlock(codeAttributedString, language: language.isEmpty ? nil : language))
                    } else {
                        // No closing ``` found
                        currentAttributedString.append(NSAttributedString(string: "```\(codeContent)", attributes: [.font: defaultFont]))
                    }
                } else {
                    // No closing ``` found
                    let remainingText = scanner.string[scanner.currentIndex...]
                    currentAttributedString.append(NSAttributedString(string: String(remainingText), attributes: [.font: defaultFont]))
                    break
                }
            } else if scanner.scanString("`") != nil {
                // Inline code
                #if os(macOS)
                let backgroundColor =  NSColor.windowBackgroundColor
                #else
                let backgroundColor = UIColor.systemBackground
                #endif
                 
                if let codeContent = scanner.scanUpToString("`") {
                    if scanner.scanString("`") != nil {
                        let codeAttributed = NSAttributedString(
                            string: codeContent,
                            attributes: [
                                .font: monoFont,
                                .backgroundColor: backgroundColor
                            ]
                        )
                        currentAttributedString.append(codeAttributed)
                    } else {
                        // No closing ` found
                        currentAttributedString.append(NSAttributedString(string: "`\(codeContent)", attributes: [.font: defaultFont]))
                    }
                } else {
                    // No closing ` found
                    currentAttributedString.append(NSAttributedString(string: "`", attributes: [.font: defaultFont]))
                }
            } else if scanner.scanString("**") != nil {
                // Bold text
                if let boldContent = scanner.scanUpToString("**") {
                    if scanner.scanString("**") != nil {
                        let boldAttributed = NSAttributedString(string: boldContent, attributes: [.font: boldFont])
                        currentAttributedString.append(boldAttributed)
                    } else {
                        // No closing ** found
                        currentAttributedString.append(NSAttributedString(string: "**\(boldContent)", attributes: [.font: defaultFont]))
                    }
                } else {
                    // No closing ** found
                    currentAttributedString.append(NSAttributedString(string: "**", attributes: [.font: defaultFont]))
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
                    currentAttributedString.append(headingAttributed)
                }
                // add newline after heading
                currentAttributedString.append(NSAttributedString(string: "\n"))
            } else {
                // Regular text
                if let textContent = scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "`*#")) {
                    let textAttributed = NSAttributedString(string: textContent, attributes: [.font: defaultFont])
                    currentAttributedString.append(textAttributed)
                } else {
                    // Handle special characters not part of markdown syntax
                    if let char = scanner.scanCharacter() {
                        currentAttributedString.append(NSAttributedString(string: String(char), attributes: [.font: defaultFont]))
                    }
                }
            }
        }

        appendCurrentAttributedString()
        return contentItems
    }
    
    private static func applyHighlighting(to contentItems: inout [ContentItem], highlightText: String) {
        for index in contentItems.indices {
            switch contentItems[index] {
            case .text(let attributedString):
                let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
                applyHighlighting(to: mutableAttributedString, highlightText: highlightText)
                contentItems[index] = .text(mutableAttributedString)
            case .codeBlock(let attributedString, let language):
                let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
                applyHighlighting(to: mutableAttributedString, highlightText: highlightText)
                contentItems[index] = .codeBlock(mutableAttributedString, language: language)
            }
        }
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
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(contentItems.enumerated()), id: \.offset) { _, item in
                switch item {
                case .text(let attributedString):
                    Text(AttributedString(attributedString))
                        .lineSpacing(2)
                        .font(.system(size: config.fontSize))
                case .codeBlock(let attributedString, let language):
                    CodeBlockView(attributedCode: attributedString, language: language)
                }
            }
        }
    }
}
