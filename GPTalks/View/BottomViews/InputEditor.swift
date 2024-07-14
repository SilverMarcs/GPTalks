//
//  InputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI
import VisualEffectView

struct InputEditor: View {
    @Environment(\.colorScheme) var colorScheme
    
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
            #if !os(macOS)
            .padding(.trailing, leadingPadding)
            #endif
        }
        .font(.body)
        .modifier(RoundedRectangleOverlayModifier(radius: radius))
#if !os(macOS)
        .background(
            VisualEffect(colorTint: colorScheme == .dark
                         ? Color(hex: "050505")
                         : Color(hex: "FAFAFE"),
                         colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
            .cornerRadius(radius)
        )
#else
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
    
    var radius: CGFloat {
        18
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
