//
//  CodeBlockView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI

struct CodeBlockView: View {
    let parserResult: ParserResult
    
    @State private var isHovered = false
    @State private var isButtonPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            
            Divider()
            
            Text(parserResult.attributedString)
                .padding()
        }
        .modifier(RoundedRectangleOverlayModifier(radius: 8))
    }
    
    var copyButton: some View {
        Button {
            NSAttributedString(parserResult.attributedString).string.copyToPasteboard()
                self.isButtonPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isButtonPressed = false
                }
        } label: {
            Image(systemName: isButtonPressed ? "checkmark" : "doc.on.clipboard")
            .font(.system(size: 8))
            .frame(width: 7, height: 7)
            .padding(5)
            .contentShape(Rectangle())
        }
        .foregroundStyle(.primary)
        .background(
            .background.secondary,
            in: RoundedRectangle(cornerRadius: 5)
        )
        .buttonStyle(.borderless)
        .disabled(isButtonPressed)
    }
    
    var header: some View {
        HStack {
            if let codeBlockLanguage = parserResult.codeBlockLanguage {
                Text(codeBlockLanguage.capitalized)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            copyButton
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(.background.secondary)
    }
}
