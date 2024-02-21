//
//  EditingView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/02/2024.
//

import SwiftUI

struct EditingView: View {
    @Binding var editingMessage: String
    @Binding var isEditing: Bool
    let session: DialogueSession
    let conversation: Conversation
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        #if os(macOS)
            macOSEditingView
        #else
            iOSEditingView
        #endif
    }
    
    private var macOSEditingView: some View {
        VStack(spacing: 15) {
            TextEditor(text: $editingMessage)
                .padding(10)
                .font(.body)
                .background(.background.secondary)
                .scrollContentBackground(.hidden)
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(Color.secondary, lineWidth: 0.3)
                )

            editControls
        }
        .padding()
        .frame(minWidth: 400, idealWidth: 550, maxWidth: 800, minHeight: 200, idealHeight: 400, maxHeight: 600)
    }
    
#if !os(macOS)
    private var iOSEditingView: some View {
        NavigationView {
            Form {
//                SelectableTextField(text: $editingMessage)
                TextField("System Prompt", text: $editingMessage, axis: .vertical)
                    .focused($isTextFieldFocused)
            }
            .onAppear {
                isTextFieldFocused = true
            }
            .navigationBarTitle("Editing Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) {
                        isEditing = false
                    }
                    .foregroundStyle(.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        Task { @MainActor in
                            await session.edit(conversation: conversation, editedContent: editingMessage)
                        }
                        isEditing = false
                    }
                }
            }
        }
//        .presentationDetents([.medium])
    }
    #endif
    
    private var editControls: some View {
        HStack {
            Button("Cancel") {
                isEditing = false
            }
            .keyboardShortcut(.escape, modifiers: .command)

            Spacer()

            Button("Update") {
                Task { @MainActor in
                    await session.edit(conversation: conversation, editedContent: editingMessage)
                }
                isEditing = false
            }
            .keyboardShortcut(.return, modifiers: .command)
        }
    }
}

#if os(iOS)
import UIKit

struct SelectableTextField: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SelectableTextField
        
        init(_ textField: SelectableTextField) {
            self.parent = textField
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}
#endif
