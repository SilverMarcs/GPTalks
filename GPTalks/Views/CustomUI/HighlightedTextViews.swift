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
        let mutableString = NSMutableAttributedString(string: text)
        if parseMarkdown {
            Self.applyMarkdownFormatting(to: mutableString)
        }
        Self.applyHighlighting(to: mutableString, highlightText: highlightText)
        self.attributedString = mutableString
    }
    
    private static func applyMarkdownFormatting(to attributedString: NSMutableAttributedString) {
        let fullRange = NSRange(location: 0, length: attributedString.length)
        let text = attributedString.string
        let baseSize = AppConfig.shared.fontSize
        let monoFont = PlatformFont.monospacedSystemFont(ofSize: baseSize - 1, weight: .regular)

        let boldFont = PlatformFont.boldSystemFont(ofSize: baseSize)
        
        // Scale heading sizes relative to base font size
        let headingPatterns = [
            (pattern: "^### (.*?)$", size: baseSize * 1.6),  // H3
            (pattern: "^## (.*?)$", size: baseSize * 1.9),   // H2
            (pattern: "^# (.*?)$", size: baseSize * 2.2)     // H1
        ]
        
        for (pattern, size) in headingPatterns {
            let headingRegex = try! NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
            let headingMatches = headingRegex.matches(in: text, range: fullRange)
            
            for match in headingMatches.reversed() {
                if let contentRange = Range(match.range(at: 1), in: text) {
                    let headingContent = String(text[contentRange])
                    attributedString.replaceCharacters(in: match.range, with: headingContent)
                    
                    let newRange = NSRange(location: match.range.location, length: headingContent.count)
                    let headingFont = PlatformFont.systemFont(ofSize: size, weight: .bold)
                    
                    attributedString.addAttribute(.font, value: headingFont, range: newRange)
                }
            }
        }
        
        // Handle code blocks (```)
        let codeBlockPattern = try! NSRegularExpression(pattern: "```(?:[a-zA-Z]*\\n)?([\\s\\S]*?)```")
        let codeMatches = codeBlockPattern.matches(in: attributedString.string, range: NSRange(location: 0, length: attributedString.length))
        
        for match in codeMatches.reversed() {
            if let contentRange = Range(match.range(at: 1), in: attributedString.string) {
                let codeContent = String(attributedString.string[contentRange])
                attributedString.replaceCharacters(in: match.range, with: codeContent)
                
                let newRange = NSRange(location: match.range.location, length: codeContent.count)
                attributedString.addAttribute(.font, value: monoFont, range: newRange)
            }
        }
        
        // Handle inline code (single backticks)
        let inlineCodePattern = try! NSRegularExpression(pattern: "`([^`]+)`")
        let inlineCodeMatches = inlineCodePattern.matches(in: attributedString.string, range: NSRange(location: 0, length: attributedString.length))
        
        for match in inlineCodeMatches.reversed() {
            if let contentRange = Range(match.range(at: 1), in: attributedString.string) {
                let codeContent = String(attributedString.string[contentRange])
                attributedString.replaceCharacters(in: match.range, with: codeContent)
                
                let newRange = NSRange(location: match.range.location, length: codeContent.count)
                attributedString.addAttribute(.font, value: monoFont, range: newRange)
            }
        }
        
        // Handle bold text
        let boldPattern = try! NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*")
        let boldMatches = boldPattern.matches(in: attributedString.string, range: NSRange(location: 0, length: attributedString.length))
        
        for match in boldMatches.reversed() {
            if let contentRange = Range(match.range(at: 1), in: attributedString.string) {
                let boldContent = String(attributedString.string[contentRange])
                attributedString.replaceCharacters(in: match.range, with: boldContent)
                
                let newRange = NSRange(location: match.range.location, length: boldContent.count)
                attributedString.addAttribute(.font, value: boldFont, range: newRange)
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
            
            searchRange.location = foundRange.location + 1
            searchRange.length = stringLength - searchRange.location
        }
    }
    
    var body: some View {
        Text(AttributedString(attributedString))
            .lineSpacing(2)
            .font(.system(size: config.fontSize))
    }
}
