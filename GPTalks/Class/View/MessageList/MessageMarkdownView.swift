//
//  MessageMarkdownView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import MarkdownUI
import Splash
import SwiftUI

struct MessageMarkdownView: View {
    @Environment(\.colorScheme) private var colorScheme

    var text: String

    var body: some View {
        Markdown(MarkdownContent(text))
            .markdownCodeSyntaxHighlighter(.splash(theme: theme))
            .markdownBlockStyle(\.codeBlock) {
                CodeBlock(configuration: $0)
            }
    }

    struct CodeBlock: View {
        @State private var isHovered = false
        let configuration: CodeBlockConfiguration

        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                configuration.label
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.97))
                    }
                    .padding(12)
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .markdownMargin(top: .zero, bottom: .em(0.8))

                CodeCopyButton(text: configuration.content)
                    .padding(8)
                    .opacity(isHovered ? 1 : 0)
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
        }
    }

    struct CodeCopyButton: View {
        @State private var isButtonPressed = false
        var text: String

        var body: some View {
            Button(action: {
                self.isButtonPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isButtonPressed = false
                }
                text.copyToPasteboard()
            }) {
                Image(systemName: isButtonPressed ? "checkmark" : "clipboard")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 9, height: 19)
                    .padding(.vertical, 1)
                    .padding(.horizontal, 1)
            }
            .disabled(isButtonPressed)
            .background(.background)
            .cornerRadius(5)
        }
    }

    private var theme: Splash.Theme {
        switch colorScheme {
        case .dark:
            return .wwdc17(withFont: .init(size: 16))
        default:
            return .sunset(withFont: .init(size: 16))
        }
    }
}
