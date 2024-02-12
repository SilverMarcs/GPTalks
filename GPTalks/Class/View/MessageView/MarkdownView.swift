//
//  MessageMarkdownView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import MarkdownUI
//import Splash
import SwiftUI
#if !os(visionOS)
import MarkdownWebView
#endif

struct MarkdownView: View {
    @Environment(\.colorScheme) private var colorScheme

    var text: String

    var body: some View {
//        if AppConfiguration.shared.alternateMarkdown {
        #if !os(visionOS)
            if text.isEmpty {
                EmptyView()
            } else {
                MarkdownWebView(text)
            }
        #else
//        } else {
            Markdown(text)
//                .markdownCodeSyntaxHighlighter(.splash(theme: theme))
                .markdownBlockStyle(\.codeBlock) {
                    CodeBlock(configuration: $0)
                }
        #endif
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
                    .padding(5)
            }
            #if os(macOS)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
            #endif
        }

        var copyButton: some View {
            Button {
                self.isButtonPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isButtonPressed = false
                }
                configuration.content.copyToPasteboard()
            } label: {
                Image(systemName: isButtonPressed ? "checkmark" : "clipboard")
                .font(.system(size: 12))
                .frame(width: 12, height: 12)
                .padding(9)
                .contentShape(Rectangle())
            }
            .foregroundStyle(.primary)
#if os(macOS)
            .background(
                .background.tertiary,
                in: RoundedRectangle(cornerRadius: 5, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(.quaternary, lineWidth: 0.6)
            }
            .opacity((isHovered || isButtonPressed) ? 1 : 0)
            #endif
            .buttonStyle(.borderless)
            .disabled(isButtonPressed)
        }
    }

//    private var theme: Splash.Theme {
//        switch colorScheme {
//        case .dark:
//            return .wwdc17(withFont: .init(size: 16))
//        default:
//            return .sunset(withFont: .init(size: 16))
//        }
//    }
//}
