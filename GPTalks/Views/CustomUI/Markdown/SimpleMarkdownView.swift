//
//  SimpleMarkdownView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/12/2024.
//


import SwiftUI

enum ContentBlock: Hashable {
    case code(String)
    case text(String)
}

struct SimpleMarkdownView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var config = AppConfig.shared
    var contentBlocks: [ContentBlock]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(contentBlocks, id: \.self) { block in
                switch block {
                case .code(let code):
                    Text(code)
                        .font(.system(size: config.fontSize - 1, design: .monospaced))
                        .padding()
                        .roundedRectangleOverlay(radius: 6)
                        .background(color.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
                case .text(let text):
                    Text(LocalizedStringKey(text))
                        .font(.system(size: config.fontSize))
                }
            }
        }
        .lineSpacing(2)
        .textSelection(.enabled)
    }
    
    init(text: String) {
        self.contentBlocks = SimpleMarkdownView.parseMarkdown(text)
    }
    
    var color: Color {
        colorScheme == .dark ? .black : .gray
    }

    private static func parseMarkdown(_ text: String) -> [ContentBlock] {
        var blocks: [ContentBlock] = []
        let scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = nil

        while !scanner.isAtEnd {
            if scanner.scanString("```") != nil {
                _ = scanner.scanUpToCharacters(from: .newlines)
                _ = scanner.scanCharacters(from: .newlines) // Skip newline after language
                
                if var codeContent = scanner.scanUpToString("```") {
                    if scanner.scanString("```") != nil {
                        // Remove trailing newline if any
                        if codeContent.last == "\n" {
                            codeContent.removeLast()
                        }
                        blocks.append(.code(codeContent))
                    } else {
                        // No closing ``` found
                        blocks.append(.code("```\(codeContent)"))
                    }
                } else {
                    // No closing ``` found
                    let remainingText = scanner.string[scanner.currentIndex...]
                    blocks.append(.code(String(remainingText)))
                    break
                }
            } else {
                // Regular text
                if let textContent = scanner.scanUpToString("```") {
                    blocks.append(.text(textContent.trimmingCharacters(in: .whitespacesAndNewlines)))
                }
            }
        }

        return blocks
    }
}
