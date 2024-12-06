//
//  NativeMarkdownView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/11/2024.
//

import SwiftUI
import Markdown
import LaTeXSwiftUI

struct NativeMarkdownView: View {
    @ObservedObject var config = AppConfig.shared
    
    let contentItems: [ContentItem]
    
    init(content: String, searchText: String) {
        let document = Document(parsing: content, options: [.parseBlockDirectives])
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
//                    .padding(.vertical, 8)
            case .table(let table):
                 TableView(table: table)
                    .padding(.top, -10)
                    .padding(.bottom, 8)
            case .latex(let latexString):
                LaTeX(latexString)
                    .scrollDisabled(true)
                    .parsingMode(.all)
                    .renderingStyle(.progress)
                    .renderingAnimation(.easeIn)
                    .frame(height: 40)
            case .list(let type, let items):
                ListView(type: type, items: items)
                    .padding(.top, -10)
                    .padding(.bottom, 4)
            }
        }
    }
}

struct ListView: View {
    let type: ListType
    let items: [NSAttributedString]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top) {
                    Text(type == .ordered ? "\(index + 1)." : "•")
                    
                    Text(AttributedString(item))
                        .lineSpacing(2)
                }
            }
        }
        .padding(.leading, 8)
    }
}

#Preview {
    List {
        NativeMarkdownView(content: "Hello, **world**!", searchText: "")
    }
}
