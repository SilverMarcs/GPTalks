//
//  MarkdownView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/11/2024.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
typealias TTFont = UIFont
typealias TTFontDescriptor = UIFontDescriptor
typealias TTColor = UIColor
#else
import AppKit
typealias TTFont = NSFont
typealias TTFontDescriptor = NSFontDescriptor
typealias TTColor = NSColor
#endif

import Markdown
import Foundation
//import Highlighter

/// Based on the source code from Christian Selig
/// https://github.com/christianselig/Markdownosaur/blob/main/Sources/Markdownosaur/Markdownosaur.swift

public struct MarkdownParser: MarkupVisitor {
    let baseSize = AppConfig.shared.fontSize
    
    let defaultFont = PlatformFont.systemFont(ofSize:  AppConfig.shared.fontSize)
    let monoFont = PlatformFont.monospacedSystemFont(ofSize:  AppConfig.shared.fontSize - 1, weight: .regular)
    let boldFont = PlatformFont.boldSystemFont(ofSize:  AppConfig.shared.fontSize)
    
    let newLineFontSize: CGFloat = 12

    public init() {}

    public mutating func attributedString(from document: Document) -> NSAttributedString {
        return visit(document)
    }
  
    mutating func parserResults(from document: Document, highlightText: String) -> [ContentItem] {
        var results = [ContentItem]()
        var currentTextBuffer = NSMutableAttributedString()
        
        func appendCurrentAttrString() {
            if !currentTextBuffer.string.isEmpty {
                // Apply highlighting before appending
                applyHighlighting(to: currentTextBuffer, highlightText: highlightText)
                results.append(.text(currentTextBuffer))
                currentTextBuffer = NSMutableAttributedString()
            }
        }
        
        document.children.forEach { markup in
            if let codeBlock = markup as? CodeBlock {
                appendCurrentAttrString()
                results.append(.codeBlock(codeBlock.code.trimmingCharacters(in: .whitespacesAndNewlines), language: codeBlock.language))
            } else if let table = markup as? Table {
                appendCurrentAttrString()
                results.append(.table(table))
            } else {
                currentTextBuffer.append(visit(markup))
            }
        }
        
        appendCurrentAttrString()
        
        return results
    }

    private func applyHighlighting(to attributedString: NSMutableAttributedString, highlightText: String) {
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

    mutating public func defaultVisit(_ markup: Markup) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in markup.children {
            result.append(visit(child))
        }

        return result
    }

    mutating public func visitText(_ text: Text) -> NSAttributedString {
        return NSAttributedString(string: text.plainText, attributes: [.font: defaultFont])
    }

    mutating public func visitEmphasis(_ emphasis: Emphasis) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in emphasis.children {
            result.append(visit(child))
        }

        result.applyEmphasis()

        return result
    }

    mutating public func visitStrong(_ strong: Strong) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in strong.children {
            result.append(visit(child))
        }

        result.addAttributes([.font: boldFont])
        
        return result
    }

    mutating public func visitParagraph(_ paragraph: Paragraph) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in paragraph.children {
            result.append(visit(child))
        }

        if paragraph.hasSuccessor {
            let shouldUseSingleNewline = paragraph.successor is CodeBlock ||  paragraph.successor is Table || paragraph.isContainedInList
            let newlineType: NSAttributedString = shouldUseSingleNewline ? .singleNewline(withFontSize: newLineFontSize) : .doubleNewline(withFontSize: newLineFontSize)
            result.append(newlineType)
//            result.append(.doubleNewline(withFontSize: newLineFontSize))
        }

        return result
    }

    mutating public func visitHeading(_ heading: Heading) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in heading.children {
            result.append(visit(child))
        }

        result.applyHeading(withLevel: heading.level)

        if heading.hasSuccessor && !(heading.successor is CodeBlock) {
            result.append(.doubleNewline(withFontSize: newLineFontSize))
        }
        
        if heading.hasPredecessor && !(heading.predecessor is Paragraph) && !(heading.predecessor is CodeBlock) {
            result.insert(.singleNewline(withFontSize: newLineFontSize), at: 0)
        }

        return result
    }

    mutating public func visitLink(_ link: Link) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in link.children {
            result.append(visit(child))
        }

        let url = URL(string: link.destination!) ?? URL(string: "https://github.com/404")!

        result.addAttributes([.link: url])

        return result
    }

    mutating public func visitInlineCode(_ inlineCode: InlineCode) -> NSAttributedString {
        return NSAttributedString(string: inlineCode.code, attributes: [.font: monoFont, .backgroundColor: PlatformColor.secondarySystemFill,])
    }

    mutating public func visitCodeBlock(_ codeBlock: CodeBlock) -> NSAttributedString {
        return NSAttributedString(string: codeBlock.code)
    }

    mutating public func visitStrikethrough(_ strikethrough: Strikethrough) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in strikethrough.children {
            result.append(visit(child))
        }

        result.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: result.length))

        return result
    }

    mutating public func visitUnorderedList(_ unorderedList: UnorderedList) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for listItem in unorderedList.listItems {
            result.append(NSAttributedString(string: "-  "))
            result.append(visit(listItem))
            if listItem.hasSuccessor {
                result.append(NSAttributedString(string: "\n"))
            }
        }
        
        if unorderedList.hasSuccessor {
            result.append(NSAttributedString(string: "\n\n"))
        }
        
        return result
    }

    mutating public func visitOrderedList(_ orderedList: OrderedList) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for (index, listItem) in orderedList.listItems.enumerated() {
            result.append(NSAttributedString(string: "\(orderedList.startIndex + UInt(index)).  "))
            result.append(visit(listItem))
            if listItem.hasSuccessor {
                result.append(NSAttributedString(string: "\n"))
            }
        }
        
        if orderedList.hasSuccessor {
            result.append(NSAttributedString(string: "\n\n"))
        }
        
        return result
    }

    mutating public func visitListItem(_ listItem: ListItem) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in listItem.children {
            result.append(visit(child))
        }
        
        return result
    }

    mutating public func visitBlockQuote(_ blockQuote: BlockQuote) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in blockQuote.children {
            var quoteAttributes: [NSAttributedString.Key: Any] = [:]

            let quoteParagraphStyle = NSMutableParagraphStyle()

            let baseLeftMargin: CGFloat = 15.0
            let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(blockQuote.quoteDepth))

            quoteParagraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: leftMarginOffset)]

            quoteParagraphStyle.headIndent = leftMarginOffset

            quoteAttributes[.paragraphStyle] = quoteParagraphStyle
            quoteAttributes[.font] = defaultFont
            quoteAttributes[.listDepth] = blockQuote.quoteDepth

            let quoteAttributedString = visit(child).mutableCopy() as! NSMutableAttributedString
            quoteAttributedString.insert(NSAttributedString(string: "\t", attributes: quoteAttributes), at: 0)

            quoteAttributedString.addAttribute(.foregroundColor, value: TTColor.systemGray)

            result.append(quoteAttributedString)
        }

        if blockQuote.hasSuccessor {
            result.append(.singleNewline(withFontSize: newLineFontSize))
        }

        return result
    }
}

// MARK: - Extensions Land

extension NSMutableAttributedString {
    func applyEmphasis() {
        enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
            guard let font = value as? PlatformFont else { return }

            #if os(macOS)
            let newFont = font.apply(newTraits: .italic)
            #else
            let newFont = font.apply(newTraits: .traitItalic)
            #endif
            
            addAttribute(.font, value: newFont, range: range)
        }
    }

    func applyHeading(withLevel headingLevel: Int) {
        enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
            guard let font = value as? PlatformFont else { return }
            
            let scaleFactor: CGFloat = 1.1
            let baseHeadingSize: CGFloat = font.pointSize * 1.0
            
            let newSize = baseHeadingSize * pow(scaleFactor, CGFloat(6 - headingLevel))
            let newFont = PlatformFont.systemFont(ofSize: newSize, weight: .bold)
            
            addAttribute(.font, value: newFont, range: range)
        }
    }
}

extension TTFont {
    func apply(newTraits: TTFontDescriptor.SymbolicTraits, newPointSize: CGFloat? = nil) -> TTFont {
        var existingTraits = fontDescriptor.symbolicTraits
        existingTraits.insert(newTraits)

#if os(macOS)
        let newFontDescriptor = fontDescriptor.withSymbolicTraits(existingTraits)
        return TTFont(descriptor: newFontDescriptor, size: newPointSize ?? pointSize) ?? self
#else
        guard let newFontDescriptor = fontDescriptor.withSymbolicTraits(existingTraits) else { return self }
        return TTFont(descriptor: newFontDescriptor, size: newPointSize ?? pointSize)
#endif
    }
}

extension ListItemContainer {
    /// Depth of the list if nested within others. Index starts at 0.
    var listDepth: Int {
        var index = 0

        var currentElement = parent

        while currentElement != nil {
            if currentElement is ListItemContainer {
                index += 1
            }

            currentElement = currentElement?.parent
        }

        return index
    }
}

extension BlockQuote {
    /// Depth of the quote if nested within others. Index starts at 0.
    var quoteDepth: Int {
        var index = 0

        var currentElement = parent

        while currentElement != nil {
            if currentElement is BlockQuote {
                index += 1
            }

            currentElement = currentElement?.parent
        }

        return index
    }
}

extension NSAttributedString.Key {
    static let listDepth = NSAttributedString.Key("ListDepth")
    static let quoteDepth = NSAttributedString.Key("QuoteDepth")
}

extension NSMutableAttributedString {
    func addAttribute(_ name: NSAttributedString.Key, value: Any) {
        addAttribute(name, value: value, range: NSRange(location: 0, length: length))
    }

    func addAttributes(_ attrs: [NSAttributedString.Key : Any]) {
        addAttributes(attrs, range: NSRange(location: 0, length: length))
    }
}

extension Markup {
    /// Returns true if this element has sibling elements after it.
    var hasSuccessor: Bool {
        guard let childCount = parent?.childCount else { return false }
        return indexInParent < childCount - 1
    }
    
    var hasPredecessor: Bool {
        return indexInParent > 0
    }
    
    var predecessor: Markup? {
        guard let parent = parent else { return nil }
        let selfIndex = indexInParent
        
        for child in parent.children {
            let childIndex = child.indexInParent
            
            if childIndex == selfIndex - 1 {
                return child
            }
        }
        
        return nil
    }
    
    var successor: Markup? {
        guard let parent = parent else { return nil }
        let selfIndex = indexInParent
        
        for child in parent.children {
            let childIndex = child.indexInParent
            
            if childIndex == selfIndex + 1 {
                return child
            }
        }
        
        return nil
    }
    
    var isContainedInList: Bool {
        var currentElement = parent

        while currentElement != nil {
            if currentElement is ListItemContainer {
                return true
            }

            currentElement = currentElement?.parent
        }

        return false
    }
}

extension NSAttributedString {
    static func singleNewline(withFontSize fontSize: CGFloat) -> NSAttributedString {
        return NSAttributedString(string: "\n")
    }

    static func doubleNewline(withFontSize fontSize: CGFloat) -> NSAttributedString {
        return NSAttributedString(string: "\n\n")
    }
}
