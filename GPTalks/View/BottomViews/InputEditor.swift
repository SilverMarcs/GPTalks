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
                    .padding(.leading, leadingPadding)
                    .foregroundStyle(.placeholder)
            }
            
            TextEditor(text: $prompt)
                .focused($isFocused)
                .frame(maxHeight: maxHeight)
                .fixedSize(horizontal: false, vertical: true)
                .scrollContentBackground(.hidden)
                .padding(padding)
                .padding(.leading, leadingPadding)
        }
        .modifier(RoundedRectangleOverlayModifier(radius: 18))
        .font(.body)
        #if os(macOS)
        .onAppear {
            isFocused = true
        }
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
    
    var padding: CGFloat {
        #if os(macOS)
        return 6
        #else
        return -2
        #endif
    }
    
    var leadingPadding: CGFloat {
        #if os(macOS)
        return 0
        #else
        return 10
        #endif
    }
    
    var maxHeight: CGFloat {
        #if os(macOS)
        return 280
        #else
        return 200
        #endif
    }
}

#Preview {
    InputEditor(prompt: .constant("Hello, World!"))
}
