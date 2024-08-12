//
//  HighlightedTextViews.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/11/24.
//

import SwiftUI

struct HighlightAttribute: TextAttribute {}

extension Text.Layout {
    /// A helper function for easier access to all runs in a layout.
    var flattenedRuns: some RandomAccessCollection<Text.Layout.Run> {
        self.flatMap { line in
            line
        }
    }
}

struct HighlightTextRenderer: TextRenderer {
    private let style: any ShapeStyle
    
    init(style: any ShapeStyle = .yellow) {
        self.style = style
    }
    
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for run in layout.flattenedRuns {
            if run[HighlightAttribute.self] != nil {
                let rect = run.typographicBounds.rect
                let copy = context
                let shape = RoundedRectangle(cornerRadius: 3, style: .continuous).path(in: rect)
                copy.fill(shape, with: .style(style))
                copy.draw(run)
            } else {
                let copy = context
                copy.draw(run)
            }
        }
    }
}

extension String {
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
    
    func remainingRanges(from ranges: [Range<Index>]) -> [Range<Index>] {
        var result = [Range<Index>]()
        let sortedRanges = ranges.sorted { $0.lowerBound < $1.lowerBound }
        var currentIndex = self.startIndex
        
        for range in sortedRanges {
            if currentIndex < range.lowerBound {
                result.append(currentIndex..<range.lowerBound)
            }
            currentIndex = range.upperBound
        }
        
        if currentIndex < self.endIndex {
            result.append(currentIndex..<self.endIndex)
        }
        
        return result
    }
}

struct HighlightedText: View {
    private let text: String
    private let highlightedText: String?
    private let shapeStyle: (any ShapeStyle)?
    private let selectable: Bool
    
    init(text: String, highlightedText: String? = nil, shapeStyle: (any ShapeStyle)? = nil, selectable: Bool = true) {
        self.text = text
        self.highlightedText = highlightedText
        self.shapeStyle = shapeStyle
        self.selectable = selectable
    }
    
    var body: some View {
        if let highlightedText, !highlightedText.isEmpty {
            let text = highlightedTextComponent(from: highlightedText).reduce(Text("")) { partialResult, component in
                return partialResult + component.text
            }
            text.textRenderer(HighlightTextRenderer(style: shapeStyle ?? .yellow.opacity(0.4)))
        } else {
            if selectable {
                Text(text)
                    .textSelection(.enabled)
            } else {
                Text(text)
            }   
        }
    }
    
    private func highlightedTextComponent(from highlight: String) -> [HighlightedTextComponent] {
        let highlightRanges: [HighlightedTextComponent] = text
            .ranges(of: highlight, options: .caseInsensitive)
            .map { HighlightedTextComponent(text: Text(text[$0]).customAttribute(HighlightAttribute()), range: $0)  }
        
        let remainingRanges = text
            .remainingRanges(from: highlightRanges.map(\.range))
            .map { HighlightedTextComponent(text: Text(text[$0]), range: $0)  }
        
        return (highlightRanges + remainingRanges).sorted(by: { $0.range.lowerBound < $1.range.lowerBound  } )
    }
}

fileprivate struct HighlightedTextComponent {
    let text: Text
    let range: Range<String.Index>
}

