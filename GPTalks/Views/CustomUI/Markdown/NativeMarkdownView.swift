//
//  NativeMarkdownView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct NativeMarkdownView: View {
    @ObservedObject private var config = AppConfig.shared
    var attributed: NSAttributedString

    var body: some View {
        Text(AttributedString(attributed))
            .lineSpacing(2)
            .font(.system(size: config.fontSize))
    }
    
    init(text: String, highlightText: String) {
        self.attributed = NativeMarkdownView.parseMarkdown(text)
        if !highlightText.isEmpty {
            var mutableAttributedString = NSMutableAttributedString(attributedString: self.attributed)
            NativeMarkdownView.applyHighlighting(to: &mutableAttributedString, highlightText: highlightText)
            self.attributed = mutableAttributedString
        }
    }

    private static func parseMarkdown(_ text: String) -> NSAttributedString {
        let currentAttributedString = NSMutableAttributedString()
        
        let scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = nil

        let baseSize = AppConfig.shared.fontSize
        let defaultFont = PlatformFont.systemFont(ofSize: baseSize)
        let monoFont = PlatformFont.monospacedSystemFont(ofSize: baseSize - 1, weight: .regular)
        let boldFont = PlatformFont.boldSystemFont(ofSize: baseSize)

        while !scanner.isAtEnd {
            if scanner.scanString("```") != nil {
                let _ = scanner.scanUpToCharacters(from: .newlines) ?? ""
                let _ = scanner.scanCharacters(from: .newlines) // Skip newline after language
                
                if var codeContent = scanner.scanUpToString("```") {
                    if scanner.scanString("```") != nil {
                        // remove trailing newline if any
                        if codeContent.last == "\n" {
                            codeContent.removeLast()
                        }
                        currentAttributedString.append(NSAttributedString(string: codeContent, attributes: [.font: monoFont]))
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
                if let codeContent = scanner.scanUpToString("`") {
                    if scanner.scanString("`") != nil {
                        let codeAttributed = NSAttributedString(
                            string: codeContent,
                            attributes: [
                                .font: monoFont,
                                .backgroundColor: PlatformColor.secondarySystemFill,
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
//                currentAttributedString.append(NSAttributedString(string: "\n"))
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

        return currentAttributedString
    }

    private static func applyHighlighting(to attributedString: inout NSMutableAttributedString, highlightText: String) {
        if highlightText.isEmpty {
            return
        }
        
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
}


#Preview {
    List {
        NativeMarkdownView(text: "Hello, **world**!", highlightText: "")
    }
}
