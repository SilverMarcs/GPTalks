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
    @Environment(SessionVM.self) var sessionVM
    
    @Binding var prompt: String
    @FocusState var isFocused: Bool
    
    @State var showPopover: Bool = false
    
    var body: some View {
        inputView
        .font(.body)
        .onAppear {
            if !isIPadOS() && !AppConfig.shared.sidebarFocus {
                DispatchQueue.main.async { isFocused = true }
            }
        }
    }
    
    #if os(macOS)
    @ViewBuilder
    var inputView: some View {
        ZStack(alignment: .leading) {
            if prompt.isEmpty {
                Text("Prompt")
                    .padding(padding)
                    .padding(.leading, 6)
                    .padding(.leading, leadingPadding)
                    .foregroundStyle(.placeholder)
            }
            
            TextEditor(text: $prompt)
                .focused($isFocused)
                .frame(maxHeight: 400)
                .fixedSize(horizontal: false, vertical: true)
                .scrollContentBackground(.hidden)
                .padding(padding)
                .padding(.leading, leadingPadding)
        }
        .onChange(of: sessionVM.selections) {
            if !isIPadOS() && !AppConfig.shared.sidebarFocus {
                isFocused = true 
            }
        }
        .modifier(RoundedRectangleOverlayModifier(radius: radius))
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {
                    isFocused = true
                    AppConfig.shared.sidebarFocus = false
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
                .keyboardShortcut("l", modifiers: .command)
            }
        }
    }
    #else
    var inputView: some View {
        ZStack(alignment: .bottomTrailing) {
            TextField("Send a message", text: $prompt, axis: .vertical)
                .focused($isFocused)
                .padding(padding)
                .padding(.leading, 5)
                .lineLimit(10)
                .modifier(RoundedRectangleOverlayModifier(radius: radius))
                .background(
                    VisualEffect(colorTint: colorScheme == .dark
                                 ? Color(hex: "050505")
                                 : Color(hex: "FAFAFE"),
                                 colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
                    .cornerRadius(radius)
                )
            
            if isIOS() && prompt.count > 25 {
                ExpandButton(size: 25) { showPopover.toggle() }
                    .padding(5)
                    .sheet(isPresented: $showPopover) {
                        ExpandedTextField(prompt: $prompt)
                    }
    
            }
        }
    }
    #endif

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
