//
//  TextSelectionView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/01/2024.
//

import SwiftUI

struct TextSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var content: String

    var body: some View {
        NavigationStack {
            ScrollView {
                MarkdownView(content: content)
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
