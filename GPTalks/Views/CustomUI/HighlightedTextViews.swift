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
        if let highlightedText, highlightedText.count >= 3 {
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
            
            // Set background color to a brighter yellow and foreground color to black
            attributedString.addAttributes(
                [
                    .backgroundColor: PlatformColor.yellow,
                    .foregroundColor: PlatformColor.black
                ],
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
