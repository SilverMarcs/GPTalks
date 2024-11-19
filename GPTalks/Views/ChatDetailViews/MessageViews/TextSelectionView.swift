//
//  TextSelectionView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/01/2024.
//

import SwiftUI
import SwiftMarkdownView

struct TextSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var config = AppConfig.shared
    
    var content: String

    var body: some View {
        NavigationStack {
            ScrollView {
                SwiftMarkdownView(content)
                    .markdownBaseURL("GPTalks Web Content")
                    .codeBlockTheme(config.codeBlockTheme)
            }
            .safeAreaPadding(.horizontal)
            .navigationTitle("Select Text")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
