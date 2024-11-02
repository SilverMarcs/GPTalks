//
//  HighlightedTextViews.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/11/24.
//

import SwiftUI

struct HighlightedText: View {
    let text: String
    let highlightedText: String?
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
        if let highlightedText, !highlightedText.isEmpty {
            AttributedText(
                text: text,
                highlightText: highlightedText
            )
        } else {
            Text(text)
        }
    }
}

struct AttributedText: View {
    let attributedString: NSAttributedString
    
    init(text: String, highlightText: String) {
        let attributedString = NSMutableAttributedString(string: text)
        let nsString = text as NSString
        let _ = (highlightText as NSString).length
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
            
            attributedString.addAttribute(
                .backgroundColor,
                value: PlatformColor.yellow.withAlphaComponent(0.4),
                range: foundRange
            )
            
            searchRange.location = foundRange.location + 1
            searchRange.length = stringLength - searchRange.location
        }
        
        self.attributedString = attributedString
    }
    
    var body: some View {
        Text(AttributedString(attributedString))
    }
}

#if os(macOS)
typealias PlatformColor = NSColor
#else
typealias PlatformColor = UIColor
#endif

