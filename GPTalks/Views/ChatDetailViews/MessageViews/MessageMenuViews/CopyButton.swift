//
//  CopyButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct CopyButton: View {
    let content: String
    let dataFiles: [TypedData]
    
    @State private var isCopied = false

    var body: some View {
        Menu {
            if !dataFiles.isEmpty {
                Button {
                    var finalString = dataFiles.map { $0.formattedTextContent }.joined()
                    finalString += content
                    finalString.copyToPasteboard()
                } label: {
                    Label("Copy Files", systemImage: "doc.richtext")
                }
            }
        } label: {
            Label("Copy", systemImage: isCopied ? "checkmark" : "paperclip")
        } primaryAction: {
            content.copyToPasteboard()
            isCopied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isCopied = false
            }
        }
        .contentTransition(.symbolEffect(.replace))
        .frame(width: 15)
    }
}
