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
            Group {
                #if !os(macOS)
                SelectableTextView(text: content)
                #else
                Text(content)
                #endif
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

#if !os(macOS)
struct SelectableTextView: UIViewRepresentable {
    let text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: UIFont.systemFontSize + 2)
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.textContainer.lineFragmentPadding = 0
        // TODO: contentInsetAdjustmentBehavior
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.sizeToFit()
    }
}
#endif
