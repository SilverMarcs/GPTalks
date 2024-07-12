//
//  InputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct InputEditor: View {
    @Binding var prompt: String
    @FocusState var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            if prompt.isEmpty {
                Text("Send a message")
                    .padding(padding)
                    .padding(.leading, 6)
                    .foregroundStyle(.placeholder)
            }
            
            TextEditor(text: $prompt)
                .focused($isFocused)
                .frame(maxHeight: 400)
                .fixedSize(horizontal: false, vertical: true)
                .scrollContentBackground(.hidden)
                .padding(padding)
                .modifier(RoundedRectangleOverlayModifier(radius: 18))
        }
        .onAppear {
            isFocused = true
        }
        .font(.body)
        #if os(macOS)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {
                    isFocused = true
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
                .keyboardShortcut("l", modifiers: .command)
            }
        }
        #endif
    }
    
    var padding: CGFloat = 6
}

#Preview {
    InputEditor(prompt: .constant("Hello, World!"))
}
