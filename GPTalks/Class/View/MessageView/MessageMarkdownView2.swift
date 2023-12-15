//
//  MessageMarkdownView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import MarkdownUI
import Splash
import SwiftUI

struct MessageMarkdownView2: View {
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
        let configuration: CodeBlockConfiguration

        @State private var isHovered = false
        @State private var isButtonPressed = false

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

                copyButton
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
        }

        var copyButton: some View {
            Button(action: {
                self.isButtonPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isButtonPressed = false
                }
                configuration.content.copyToPasteboard()
            }) {
                Image(systemName: isButtonPressed ? "checkmark" : "clipboard")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonWidth, height: buttonHeight)
            }
            .buttonStyle(.plain)
            .disabled(isButtonPressed)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            #if os(macOS)
                .opacity((isHovered || isButtonPressed) ? 1 : 0)
            #endif
        }

        private var buttonHeight: CGFloat {
            #if os(macOS)
                20
            #else
                22
            #endif
        }

        private var buttonWidth: CGFloat {
            #if os(macOS)
                10
            #else
                12
            #endif
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
