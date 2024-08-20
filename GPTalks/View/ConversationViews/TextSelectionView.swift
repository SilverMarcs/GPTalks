//
//  TextSelectionView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/01/2024.
//

import SwiftUI
import SelectableText

struct TextSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var content: String

    var body: some View {
        NavigationStack {
            ScrollView {
                TextEditor(text: .constant(content))
                    .scrollDisabled(true)
                    .padding(.horizontal)
            }
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
