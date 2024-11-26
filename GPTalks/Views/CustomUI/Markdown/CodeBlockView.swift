//
//  CodeBlockView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct CodeBlockView: View {
    let code: String
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
                Text(code)
                    .font(.system(size: AppConfig.shared.fontSize - 1, design: .monospaced))
                
                Button {
                    withAnimation {
                        clicked.toggle()
                    }
                    code.copyToPasteboard()
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
        }
        .groupBoxStyle(PlatformGroupBoxStyle())
//        .background(
//            RoundedRectangle(cornerRadius: 5)
//                .fill(Color(.textBackgroundColor).opacity(0.5))
//        )
    }
}

#Preview {
    CodeBlockView(code: .codeBlock, language: "Swift")
}
