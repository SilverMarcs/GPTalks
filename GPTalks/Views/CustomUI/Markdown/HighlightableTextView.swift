//
//  HighlightableTextView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/11/24.
//

import SwiftUI

struct HighlightableTextView: View {
    let attributedText: AttributedString
    
    init(text: String, highlightedText: String) {
        self.attributedText = HighlightableTextView.createAttributedString(from: text, highlightedText: highlightedText)
    }
    
    var body: some View {
        Text(attributedText)
    }
    
    private static func createAttributedString(from text: String, highlightedText: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        if !highlightedText.isEmpty {
            let lowercasedHighlight = highlightedText.lowercased()
            
            var searchRange = attributedString.startIndex..<attributedString.endIndex
            
            while let range = attributedString[searchRange].range(of: lowercasedHighlight, options: .caseInsensitive) {
                attributedString[range].backgroundColor = .yellow
                attributedString[range].foregroundColor = .black
                
                if range.upperBound >= searchRange.upperBound {
                    break
                }
                searchRange = range.upperBound..<searchRange.upperBound
            }
        }
        
        return attributedString
    }
}
