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
        Group {
            #if os(macOS)
            macosView
            #else
            iosView
            #endif
        }
        .font(.body)
        .onAppear {
            isFocused = true
        }

    }
    
    #if !os(macOS)
    var iosView: some View {
        TextField("Send a message", text: $prompt, axis: .vertical)
            .padding(padding)
            .padding(.leading, 5)
            .lineLimit(12)
            .modifier(RoundedRectangleOverlayModifier(radius: radius))
            .background(
                VisualEffect(colorTint: colorScheme == .dark
                             ? Color(hex: "050505")
                             : Color(hex: "FAFAFE"),
                             colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
                .cornerRadius(radius)
            )
    }
    #endif
    
    @ViewBuilder
    var macosView: some View {
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
                .frame(maxHeight: 280)
                .fixedSize(horizontal: false, vertical: true)
                .scrollContentBackground(.hidden)
                .padding(padding)
                .padding(.leading, leadingPadding)
        }
        .modifier(RoundedRectangleOverlayModifier(radius: radius))
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
    }
    
    var radius: CGFloat {
        18
    }
    
    var padding: CGFloat {
        #if os(macOS)
        return 6
        #else
        return 6
        #endif
    }
    
    var leadingPadding: CGFloat {
        #if os(macOS)
        return 0
        #else
        return 10
        #endif
    }
}

#Preview {
    InputEditor(prompt: .constant("Hello, World!"))
}
