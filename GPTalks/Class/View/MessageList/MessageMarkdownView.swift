//
//  MessageMarkdownView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/7.
//

import MarkdownUI
import SwiftUI
import Splash

struct MessageMarkdownView: View {
    @Environment(\.colorScheme) private var colorScheme

    var text: String

    var body: some View {
        Markdown(MarkdownContent(text))
            .markdownCodeSyntaxHighlighter(.splash(theme: theme))
            .markdownBlockStyle(\.codeBlock) {
              codeBlock($0)
            }
    }
    
    private var theme: Splash.Theme {
      switch self.colorScheme {
      case .dark:
        return .wwdc17(withFont: .init(size: 16))
      default:
        return .sunset(withFont: .init(size: 16))
      }
    }
    
    @ViewBuilder
    private func codeBlock(_ configuration: CodeBlockConfiguration) -> some View {
      HStack {
          configuration.label
            .markdownTextStyle {
              FontFamilyVariant(.monospaced)
              FontSize(.em(0.97))
            }
            .padding(15)
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .markdownMargin(top: .zero, bottom: .em(0.8))
          CodeCopyButton(text: configuration.content)
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
            }
            .disabled(isButtonPressed)
            .buttonStyle(.plain)
        }
    }
}
