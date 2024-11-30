//
//  BasicMarkdownView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/11/2024.
//

import SwiftUI
import Markdown

struct BasicMarkdownView: View {
    @ObservedObject var config = AppConfig.shared
    
    let contentItems: [ParserResult]
    
    init(content: String) {
        self.contentItems = Self.parse(text: content)
    }
    
    var body: some View {
//        ForEach(Array(contentItems.enumerated()), id: \.offset) { _, item in
        ForEach(contentItems) { item in
            if let code = item.code {
                CodeBlockView(code: code, language: nil)
                    .padding(.top, -10)
                    .padding(.bottom, 8)
            } else if let text = item.attributedString {
                Text(AttributedString(text))
                    .lineSpacing(2)
//                    .font(.system(size: config.fontSize))
            } else {
                Text("Should not reach here")
            }
        }
    }

    static func parse(text: String) -> [ParserResult] {
        let document = Document(parsing: text)
        var markdownParser = AdvancedMarkdownParser()
        let results = markdownParser.parserResults(from: document)
        return results
    }
}
