//
//  TextSelectionView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/01/2024.
//

import MarkdownWebView
import SwiftUI

#if os(iOS)
struct TextSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var content: String

    var body: some View {
        NavigationView {
            ScrollView {
                MarkdownWebView(content)
                    .padding(.horizontal)
                    .padding(.bottom, 45)
            }

            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("Select Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
#endif
