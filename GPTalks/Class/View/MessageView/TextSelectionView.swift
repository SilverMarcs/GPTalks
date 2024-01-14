//
//  TextSelectionView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/01/2024.
//

import SwiftUI
import MarkdownWebView

#if os(iOS)
struct TextSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var content: String
    
    var body: some View {
        NavigationView {
            ScrollView {
                MarkdownWebView(content)
            }
            .padding()
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
