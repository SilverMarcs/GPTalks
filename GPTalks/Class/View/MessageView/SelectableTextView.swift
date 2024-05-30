//
//  SelectableTextView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 29/05/2024.
//

#if !os(macOS)
import SwiftUI
import UIKit

struct TextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    @Binding var dynamicHeight: CGFloat

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewWrapper

        init(parent: TextViewWrapper) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.dynamicHeight = textView.contentSize.height
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = []
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.backgroundColor = UIColor.clear

        // Enable word-by-word selection
        textView.allowsEditingTextAttributes = true
        textView.isScrollEnabled = false

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        DispatchQueue.main.async {
            self.dynamicHeight = uiView.contentSize.height
        }
    }
}


#endif
