//
//  MessageRowiew.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
import Markdown
import MarkdownWebView

struct MarkdownView: View {
    @ObservedObject var config = AppConfig.shared
    var content: String
    
    var body: some View {
        switch config.markdownProvider {
            case .webview:
                MarkdownWebView(content)
            case .markdownosaur:
                markdownosaur
            case .native:
                Text(LocalizedStringKey(content))
            case .disabled:
                Text(content)
        }
    }
    
    @ViewBuilder
    var markdownosaur: some View {
        let parsed = parse(text: content)
        
        VStack(alignment: .leading, spacing: 0) {
            ForEach(parsed) { parsed in
                if parsed.isCodeBlock {
                    CodeBlockView(parserResult: parsed)
                        .padding(.vertical, 15)
                    
                } else {
                    Text(parsed.attributedString)
                }
            }
        }
    }

    func parse(text: String) -> [ParserResult] {
        let document = Document(parsing: text)
        var markdownParser = Markdownosaur(theme: config.markdownTheme)
        let results = markdownParser.parserResults(from: document)
        return results
    }
}
