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
            AttributedTextView(
                text: text,
                highlightText: highlightedText,
                parseMarkdown: false
            )
        } else {
            Text(text)
        }
    }
}
