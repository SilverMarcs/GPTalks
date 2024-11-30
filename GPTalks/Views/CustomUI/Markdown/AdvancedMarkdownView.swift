//
//  AdvancedMarkdownView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/11/2024.
//

import SwiftUI
import Markdown

struct AdvancedMarkdownView: View {
    @ObservedObject var config = AppConfig.shared
    
    let contentItems: [ContentItem]
    
    init(content: String) {
        self.contentItems = Self.parse(text: content)
    }
    
    var body: some View {
        ForEach(Array(contentItems.enumerated()), id: \.offset) { _, item in
            switch item {
            case .text(let attributedString):
                Text(AttributedString(attributedString))
                    .lineSpacing(2)
                    .font(.system(size: config.fontSize))
            case .codeBlock(let codeString, let language):
                CodeBlockView(code: codeString, language: language)
                    .padding(.top, -10)
                    .padding(.bottom, 8)
            }
        }
//        ForEach(contentItems) { item in
//            if let code = item.code {
//                CodeBlockView(code: code, language: nil)
//                    .padding(.top, -10)
//                    .padding(.bottom, 8)
//            } else if let text = item.attributedString {
//                Text(AttributedString(text))
//                    .lineSpacing(2)
////                    .font(.system(size: config.fontSize))
//            } else {
//                Text("Should not reach here")
//            }
//        }
    }

    static func parse(text: String) -> [ContentItem] {
        let document = Document(parsing: text)
        var markdownParser = AdvancedMarkdownParser()
        let results = markdownParser.parserResults2(from: document)
        return results
    }
}
