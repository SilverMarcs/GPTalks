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
        let configuration: CodeBlockConfiguration

//        var body: some View {
//            ZStack(alignment: .bottomTrailing) {
//                configuration.label
//                    .markdownTextStyle {
//                        FontFamilyVariant(.monospaced)
//                        FontSize(.em(0.97))
//                    }
//                    .padding(12)
//                    .background(.background.secondary)
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                    .markdownMargin(top: .zero, bottom: .em(0.8))
//
//                CodeCopyButton(text: configuration.content)
//                    .padding(8)
//                #if os(macOS)
//                    .opacity(isHovered ? 1 : 0)
//                #endif
//            }
//            .onHover { hovering in
//                withAnimation(.easeInOut(duration: 0.2)) {
//                    isHovered = hovering
//                }
//            }
//        }
        
        var body: some View {
//            VStack(alignment: .leading, spacing: 6) {
            VStack {
                configuration.label
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.97))
                    }
                    .padding(12)
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .markdownMargin(top: .zero, bottom: .em(0.8))
//                Button {
//                    configuration.content.copyToPasteboard()
//                } label: {
//                    Image(systemName: "clipboard")
//                }
                       
//                CodeCopyButton(text: configuration.content)
//                #if os(macOS)
//                    .opacity(isHovered ? 1 : 0)
//                #endif
                    .padding(.bottom, 1)
                }
//            .onHover { hovering in
//                withAnimation(.easeInOut(duration: 0.2)) {
//                    isHovered = hovering
//                }
            
//            }
//                Button {
//                    
//                } label: {
//                    
//                }
                
//                Button {
//                    configuration.content.copyToPasteboard()
//                } label: {
//                    Text("Copy")
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 3)
//                        .background(.background.tertiary)
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color(.darkGray), lineWidth: 1)
//                        )
//                }
//                .buttonStyle(.plain)
//                .background(Color("DarkGray"))
//                 .cornerRadius(10)
//                .buttonStyle(.borderedProminent)
//                .tint(Color("DarkGray"))
//                .clipShape(.capsule(style: .circular))
//                .tint(Color.darkGray)
//                .background(
//                  RoundedRectangle(cornerRadius: 10)
//                    .stroke(.blue, lineWidth: 1)
//                )
                
//                CodeCopyButton(text: configuration.content)
//                    .padding(8)
//                #if os(macOS)
//                    .opacity(isHovered ? 1 : 0)
//                #endif
//            }
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
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .fixedSize()
//                    .frame(width: buttonWidth, height: buttonHeight)
//                    .padding(.vertical, 1)
//                    .padding(.horizontal, 1)
            }
            .buttonStyle(.borderless)
//            .disabled(isButtonPressed)
//            #if os(macOS)
//            .background(.background)
//            #endif
//            .cornerRadius(5)
        }
        
    }

    struct CodeCopyButton2: View {
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
                    .frame(width: buttonWidth, height: buttonHeight)
                    .padding(.vertical, 1)
                    .padding(.horizontal, 1)
            }
            .disabled(isButtonPressed)
            #if os(macOS)
            .background(.background)
            #endif
            .cornerRadius(5)
        }
    
        private var buttonHeight: CGFloat {
            #if os(macOS)
            19
            #else
            22
            #endif
        }
        
        private var buttonWidth: CGFloat {
            #if os(macOS)
            9
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
