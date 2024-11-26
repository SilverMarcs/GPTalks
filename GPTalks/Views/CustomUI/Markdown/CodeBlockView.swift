//
//  CodeBlockView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct CodeBlockView: View {
    let attributedCode: NSAttributedString
    let language: String?
    
    @State var clicked = false
    
    var body: some View {
//            if let language = language {
//                Text(language)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
        GroupBox {
            ZStack(alignment: .bottomTrailing) {
                Text(AttributedString(attributedCode))
                    .font(.system(size: AppConfig.shared.fontSize - 1, design: .monospaced))
                
                Button {
                    withAnimation {
                        clicked.toggle()
                    }
                    attributedCode.string.copyToPasteboard()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            clicked.toggle()
                        }
                    }
                } label: {
                    Image(systemName: clicked ? "checkmark" : "doc.on.clipboard")
                        .imageScale(.medium)
                }
                .contentTransition(.symbolEffect(.replace))
                .padding(5)
                .buttonStyle(.plain)
            }
            .padding(5)
        }
        .groupBoxStyle(PlatformGroupBoxStyle())
        #if os(macOS)
        .padding(.leading)
        #endif
        .padding(.vertical, -10)
//        .background(
//            RoundedRectangle(cornerRadius: 5)
//                .fill(Color(.textBackgroundColor).opacity(0.5))
//        )
    }
}

#Preview {
    CodeBlockView(attributedCode: NSAttributedString(string: .codeBlock), language: "Swift")
}
