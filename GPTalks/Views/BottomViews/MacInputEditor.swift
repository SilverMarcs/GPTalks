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
    @FocusState var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            if prompt.isEmpty {
                Text(placeHolder)
                    .padding(.leading, 5)
                    .foregroundStyle(.placeholder)
            }
            
            TextEditor(text: $prompt)
                .focused($isFocused)
                .frame(maxHeight: 400)
                .fixedSize(horizontal: false, vertical: true)
                .scrollContentBackground(.hidden)
        }
        .font(.body)
        .onChange(of: sessionVM.chatSelections) {
            guard sessionVM.chatSelections.count == 1 else { return }
            isFocused = true
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {
                    isFocused = true
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
