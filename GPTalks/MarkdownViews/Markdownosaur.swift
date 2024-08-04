//
//  Markdownosaur.swift
//  Markdownosaur
//
//  Created by Christian Selig on 2021-11-02.
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
import Highlightr

public struct Markdownosaur: MarkupVisitor {
    #if os(macOS)
    let baseFontSize: CGFloat = 13.5
    #else
    let baseFontSize: CGFloat = 17
    #endif
    let highlighter: Highlightr

    init(theme: HighlightTheme = .xcode) {
        self.highlighter = {
            let highlighter = Highlightr()!
            highlighter.setTheme(theme)
            return highlighter
        }()
    }
    
    public mutating func attributedString(from document: Document) -> NSAttributedString {
        return visit(document)
    }
    
    mutating func parserResults(from document: Document) -> [ParserResult] {
        var results = [ParserResult]()
        var currentAttrString = NSMutableAttributedString()
        
        func appendCurrentAttrString() {
            if !currentAttrString.string.isEmpty {
                #if os(macOS)
                let currentAttrStringToAppend = (try? AttributedString(currentAttrString, including: \.appKit)) ?? AttributedString(stringLiteral: currentAttrString.string)
                #else
                let currentAttrStringToAppend = (try? AttributedString(currentAttrString, including: \.uiKit)) ?? AttributedString(stringLiteral: currentAttrString.string)
                #endif
                results.append(.init(attributedString: currentAttrStringToAppend, isCodeBlock: false, codeBlockLanguage: nil))
            }
        }
        
        document.children.forEach { markup in
            let attrString = visit(markup)
            if let codeBlock = markup as? CodeBlock {
                appendCurrentAttrString()
                #if os(macOS)
                let attrStringToAppend = (try? AttributedString(attrString, including: \.appKit)) ?? AttributedString(stringLiteral: attrString.string)
                #else
                let attrStringToAppend = (try? AttributedString(attrString, including: \.uiKit)) ?? AttributedString(stringLiteral: attrString.string)
                #endif
                results.append(.init(attributedString: attrStringToAppend, isCodeBlock: true, codeBlockLanguage: codeBlock.language))
                currentAttrString = NSMutableAttributedString()
            } else {
                currentAttrString.append(attrString)
            }
        }
         
        appendCurrentAttrString()
        return results
    }
    
    mutating public func defaultVisit(_ markup: Markup) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in markup.children {
            result.append(visit(child))
        }
        
        return result
    }
    
    mutating public func visitText(_ text: Text) -> NSAttributedString {
        return NSAttributedString(string: text.plainText, attributes: [.font: TTFont.systemFont(ofSize: baseFontSize, weight: .regular)])
    }
    
    mutating public func visitEmphasis(_ emphasis: Emphasis) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in emphasis.children {
            result.append(visit(child))
        }
        
        result.applyEmphasis()
        
        return result
    }
    
    mutating public func visitSoftBreak(_ softBreak: SoftBreak) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in softBreak.children {
            result.append(visit(child))
        }
        result.append (.singleNewline(withFontSize: baseFontSize))

        return result
    }
    
    mutating public func visitStrong(_ strong: Strong) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in strong.children {
            result.append(visit(child))
        }
        
        result.applyStrong()
        
        return result
    }
    
    mutating public func visitParagraph(_ paragraph: Paragraph) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in paragraph.children {
            result.append(visit(child))
        }
        
        if paragraph.hasSuccessor && !paragraph.isNextSiblingCodeBlock() {
            result.append(paragraph.isContainedInList ? .singleNewline(withFontSize: baseFontSize) : .doubleNewline(withFontSize: baseFontSize))
        }
        
        return result
    }
    
    mutating public func visitHeading(_ heading: Heading) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in heading.children {
            result.append(visit(child))
        }
        
        result.applyHeading(withLevel: heading.level + 1)
        
        if heading.hasSuccessor && !heading.isNextSiblingCodeBlock() {
            result.append(.doubleNewline(withFontSize: baseFontSize))
        }
        
        return result
    }
    
    mutating public func visitLink(_ link: Link) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in link.children {
            result.append(visit(child))
        }
        
        let url = link.destination != nil ? URL(string: link.destination!) : nil
        
        result.applyLink(withURL: url)
        
        return result
    }
    
    mutating public func visitInlineCode(_ inlineCode: InlineCode) -> NSAttributedString {
        return NSAttributedString(string: inlineCode.code, attributes: [.font: TTFont.monospacedSystemFont(ofSize: baseFontSize, weight: .regular), .foregroundColor: TTColor.mutedYellow])
    }
    
    public func visitCodeBlock(_ codeBlock: CodeBlock) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: highlighter.highlight(codeBlock.code, as: codeBlock.language, fastRender: true)
                                               ?? NSAttributedString(string: codeBlock.code))
        
        result.addAttribute(.font, value: TTFont.monospacedSystemFont(ofSize: baseFontSize - 1.25, weight: .regular))
        
        if codeBlock.hasSuccessor {
            result.deleteCharacters(in: NSRange(location: result.length - 1, length: 1))
        }
    
        return result
    }
    
    mutating public func visitStrikethrough(_ strikethrough: Strikethrough) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in strikethrough.children {
            result.append(visit(child))
        }
        
        result.applyStrikethrough()
        
        return result
    }
        
    mutating public func visitListItem(_ listItem: ListItem) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for (index, child) in listItem.children.enumerated() {
            if index > 0, child is CodeBlock {
                result.append(.doubleNewline(withFontSize: baseFontSize))
            }
            result.append(visit(child))
        }
        
        if listItem.hasSuccessor {
            result.append(.singleNewline(withFontSize: baseFontSize))
        }
        
        return result
    }
    
    mutating public func visitOrderedList(_ orderedList: OrderedList) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for (index, listItem) in orderedList.listItems.enumerated() {
            var listItemAttributes: [NSAttributedString.Key: Any] = [:]
            
            let font = TTFont.systemFont(ofSize: baseFontSize, weight: .regular)
            let numeralFont = TTFont.monospacedDigitSystemFont(ofSize: baseFontSize, weight: .regular)
            
            let listItemParagraphStyle = NSMutableParagraphStyle()
            
            // No indentation
            listItemParagraphStyle.headIndent = 0
            
            listItemAttributes[.paragraphStyle] = listItemParagraphStyle
            listItemAttributes[.font] = font
            listItemAttributes[.listDepth] = orderedList.listDepth
            
            let listItemAttributedString = visit(listItem).mutableCopy() as! NSMutableAttributedString
            
            // Same as the normal list attributes, but for prettiness in formatting we want to use the cool monospaced numeral font
            var numberAttributes = listItemAttributes
            numberAttributes[.font] = numeralFont
            
            let numberAttributedString = NSAttributedString(string: "\(index + 1). ", attributes: numberAttributes)
            listItemAttributedString.insert(numberAttributedString, at: 0)
            
            result.append(listItemAttributedString)
        }
        
        if orderedList.hasSuccessor {
            result.append(orderedList.isContainedInList ? .singleNewline(withFontSize: baseFontSize) : .doubleNewline(withFontSize: baseFontSize))
        }
        
        return result
    }
    
    mutating public func visitUnorderedList(_ unorderedList: UnorderedList) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
//        let font = TTFont.systemFont(ofSize: baseFontSize, weight: .regular)
        
        for listItem in unorderedList.listItems {
            var listItemAttributes: [NSAttributedString.Key: Any] = [:]
            
            let listItemParagraphStyle = NSMutableParagraphStyle()
            
            // No indentation
            listItemParagraphStyle.headIndent = 0
            
            listItemAttributes[.paragraphStyle] = listItemParagraphStyle
            listItemAttributes[.font] = TTFont.systemFont(ofSize: baseFontSize, weight: .regular)
            listItemAttributes[.listDepth] = unorderedList.listDepth
            
            let listItemAttributedString = visit(listItem).mutableCopy() as! NSMutableAttributedString
            listItemAttributedString.insert(NSAttributedString(string: "\t• ", attributes: listItemAttributes), at: 0)
            
            result.append(listItemAttributedString)
        }
        
        if unorderedList.hasSuccessor {
            result.append(.doubleNewline(withFontSize: baseFontSize))
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
            quoteAttributes[.font] = TTFont.systemFont(ofSize: baseFontSize, weight: .regular)
            quoteAttributes[.listDepth] = blockQuote.quoteDepth
            
            let quoteAttributedString = visit(child).mutableCopy() as! NSMutableAttributedString
            quoteAttributedString.insert(NSAttributedString(string: "\t", attributes: quoteAttributes), at: 0)
            
            quoteAttributedString.addAttribute(.foregroundColor, value: TTColor.systemGray)
            
            result.append(quoteAttributedString)
        }
        
        if blockQuote.hasSuccessor {
            result.append(.doubleNewline(withFontSize: baseFontSize))
        }
        
        return result
    }
}

// MARK: - Extensions Land

extension NSMutableAttributedString {
    func applyEmphasis() {
        enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
            guard let font = value as? TTFont else { return }
            
            #if os(macOS)
            let newFont = font.apply(newTraits: .italic)
            #else
            let newFont = font.apply(newTraits: .traitItalic)
            #endif
            addAttribute(.font, value: newFont, range: range)
        }
    }
    
    func applyStrong() {
        enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
            guard let font = value as? TTFont else { return }
            
            #if os(macOS)
            let newFont = font.apply(newTraits: .bold)
            #else
            let newFont = font.apply(newTraits: .traitBold)
            #endif
            addAttribute(.font, value: newFont, range: range)
        }
    }
    
    func applyLink(withURL url: URL?) {
        addAttribute(.foregroundColor, value: TTColor.systemBlue)
        
        if let url = url {
            addAttribute(.link, value: url)
        }
    }
    
    func applyBlockquote() {
        addAttribute(.foregroundColor, value: TTColor.systemGray)
    }
    
    func applyHeading(withLevel headingLevel: Int) {
        enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
            guard let font = value as? TTFont else { return }
            
            #if os(macOS)
            let newFont = font.apply(newTraits: .bold, newPointSize: 28.0 - CGFloat(headingLevel * 2))
            #else
            let newFont = font.apply(newTraits: .traitBold, newPointSize: 28.0 - CGFloat(headingLevel * 2))
            #endif
            addAttribute(.font, value: newFont, range: range)
        }
    }
    
    func applyStrikethrough() {
        addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue)
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
    
    func isNextSiblingCodeBlock() -> Bool {
        guard let parent = parent else { return false }
        let nextIndex = indexInParent + 1
        guard nextIndex < parent.childCount else { return false }
        return parent.child(at: nextIndex) is CodeBlock
    }
}

extension NSAttributedString {
    static func singleNewline(withFontSize fontSize: CGFloat) -> NSAttributedString {
        return NSAttributedString(string: "\n", attributes: [.font: TTFont.systemFont(ofSize: fontSize, weight: .regular)])
    }
    
    static func doubleNewline(withFontSize fontSize: CGFloat) -> NSAttributedString {
        return NSAttributedString(string: "\n\n", attributes: [.font: TTFont.systemFont(ofSize: fontSize, weight: .regular)])
    }
}

extension TTColor {
    static var mutedYellow: TTColor {
        return TTColor(red: 220/255, green: 179/255, blue: 114/255, alpha: 1.0) // Adjust these values to get
    }
}
