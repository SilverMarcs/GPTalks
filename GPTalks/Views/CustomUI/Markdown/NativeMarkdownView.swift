//
//  NativeMarkdownView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/11/2024.
//

import SwiftUI
import Markdown

struct NativeMarkdownView: View {
    @ObservedObject var config = AppConfig.shared
    
    let contentItems: [ContentItem]
    
    init(content: String, searchText: String) {
        let document = Document(parsing: content)
        var markdownParser = MarkdownParser()
        self.contentItems = markdownParser.parserResults(from: document, highlightText: searchText)
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
            case .table(let table):
                 TableView(table: table)
                    .padding(.top, -10)
                    .padding(.bottom, 8)
            }
        }
    }
}
