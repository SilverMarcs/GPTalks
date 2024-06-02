//
//  Splash.swift
//  GPTalks
//
//  Created by LuoHuanyu on 2023/3/20.
//

import MarkdownUI
import Splash
import SwiftUI

struct TextOutputFormat: OutputFormat {
    private let theme: Splash.Theme
    
    init(theme: Splash.Theme) {
        self.theme = theme
    }
    
    func makeBuilder() -> Builder {
        Builder(theme: self.theme)
    }
}

extension TextOutputFormat {
    struct Builder: OutputBuilder {
        private let theme: Splash.Theme
        private var accumulatedText: [Text]
        
        fileprivate init(theme: Splash.Theme) {
            self.theme = theme
            self.accumulatedText = []
        }
        
        mutating func addToken(_ token: String, ofType type: TokenType) {
            let color = self.theme.tokenColors[type] ?? self.theme.plainTextColor
            self.accumulatedText.append(Text(token)
                #if !os(macOS)
                .foregroundColor(.init(uiColor: color))
                #else
                .foregroundColor(.init(nsColor: color))
                #endif
            )
            
        }
        
        mutating func addPlainText(_ text: String) {
            self.accumulatedText.append(
                Text(text)
                #if !os(macOS)
                .foregroundColor(.init(uiColor: self.theme.plainTextColor))
                #else
                .foregroundColor(.init(nsColor: self.theme.plainTextColor))
                #endif
            )
        }
        
        mutating func addWhitespace(_ whitespace: String) {
            self.accumulatedText.append(Text(whitespace))
        }
        
        func build() -> Text {
            self.accumulatedText.reduce(Text(""), +)
        }
    }
}


struct SplashCodeSyntaxHighlighter: CodeSyntaxHighlighter {
    private let syntaxHighlighter: SyntaxHighlighter<TextOutputFormat>
    
    init(theme: Splash.Theme) {
        self.syntaxHighlighter = SyntaxHighlighter(format: TextOutputFormat(theme: theme))
    }
    
    func highlightCode(_ content: String, language: String?) -> Text {
        guard language != nil else {
          return Text(content)
        }
        return self.syntaxHighlighter.highlight(content)
    }
}

extension CodeSyntaxHighlighter where Self == SplashCodeSyntaxHighlighter {
    static func splash(theme: Splash.Theme) -> Self {
        SplashCodeSyntaxHighlighter(theme: theme)
    }
}

extension Splash.Theme {
    static func githubDarkDimmed(withFont font: Splash.Font) -> Splash.Theme {
        return Splash.Theme(
            font: font,
            plainTextColor: Splash.Color(
                red: 0.799,
                green: 0.797,
                blue: 0.816,
                alpha: 1
            ),
            tokenColors: [
                .keyword: Splash.Color(red: 0.977, green: 0.545, blue: 0.186, alpha: 1),  // Light orange
                .string: Splash.Color(red: 0.568, green: 0.992, blue: 0.423, alpha: 1),  // Light green
                .type: Splash.Color(red: 0.584, green: 0.706, blue: 1.000, alpha: 1),    // Light blue
                .call: Splash.Color(red: 0.580, green: 0.706, blue: 1.000, alpha: 1),    // Light blue
                .number: Splash.Color(red: 0.957, green: 0.545, blue: 0.186, alpha: 1),  // Light orange
                .comment: Splash.Color(red: 0.439, green: 0.494, blue: 0.553, alpha: 1), // Grey
                .property: Splash.Color(red: 0.584, green: 0.706, blue: 1.000, alpha: 1),// Light blue
                .dotAccess: Splash.Color(red: 0.584, green: 0.706, blue: 1.000, alpha: 1),// Light blue
                .preprocessing: Splash.Color(red: 0.977, green: 0.545, blue: 0.186, alpha: 1) // Light orange
            ],
            backgroundColor: Splash.Color(
                red: 0.121,
                green: 0.125,
                blue: 0.145,
                alpha: 1
            )
        )
    }
}
