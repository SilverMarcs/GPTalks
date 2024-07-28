//
//  TextSelectionView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/01/2024.
//

import SwiftUI

import MarkdownWebView

struct TextSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var content: String

    var body: some View {
        NavigationStack {
            ScrollView {
                #if os(visionOS)
                Text(content)
                    .padding(.horizontal)
                    .padding(.bottom, 45)
                #else
                MarkdownWebView(content)
                    .padding(.horizontal)
                    .padding(.bottom, 45)
                #endif
            }
            .edgesIgnoringSafeArea(.bottom)
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
