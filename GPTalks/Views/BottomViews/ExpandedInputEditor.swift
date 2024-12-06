//
//  ExpandedInputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 22/11/2024.
//

import SwiftUI

struct ExpandedInputEditor: View {
    @Environment(\.dismiss) var dismiss
    @Binding var prompt: String
    
    @FocusState private var isFocused: FocusedField?
    
    var body: some View {
        NavigationStack {
            TextEditor(text: $prompt)
                .focused($isFocused, equals: .textEditor)
                .task {
                    isFocused = .textEditor
                }
                .font(.body)
                .textEditorStyle(.plain)
                .safeAreaPadding()
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
                .toolbarTitleDisplayMode(.inline)
                #if os(macOS)
                .frame(width: 700, height: 700)
                #else
                .navigationTitle("Input Box")
                #endif
        }
    }
}

#Preview {
    ExpandedInputEditor(prompt: .constant("Hello, World!"))
}
