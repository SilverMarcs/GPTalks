//
//  MacInputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

#if os(macOS)
import SwiftUI

struct MacInputEditor: View {
    @Environment(ChatVM.self) private var sessionVM
    
    @Binding var prompt: String
    var provider: Provider
    @FocusState var isFocused: FocusedField?
    
    var body: some View {
        ZStack(alignment: .leading) {
            if prompt.isEmpty {
                Text(placeHolder)
                    .padding(.leading, 5)
                    .foregroundStyle(.placeholder)
            }
            
            TextEditor(text: $prompt)
                .focused($isFocused, equals: .textEditor)
                .frame(maxHeight: 400)
                .fixedSize(horizontal: false, vertical: true)
                .scrollContentBackground(.hidden)
        }
        .font(.body)
        .onChange(of: sessionVM.chatSelections) {
            guard sessionVM.chatSelections.count == 1 else { return }
            isFocused = .textEditor
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {
                    isFocused = .textEditor
                } label: {
                    Image(systemName: "pencil")
                }
                .keyboardShortcut("l")
            }
        }
    }
    
    var placeHolder: String {
        "Send a prompt • \(provider.name)"
    }
}
#endif
