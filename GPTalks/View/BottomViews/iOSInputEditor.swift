//
//  iOSInputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI
#if !os(macOS) && !targetEnvironment(macCatalyst) && !os(visionOS)
import VisualEffectView
#endif


struct iOSInputEditor: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var prompt: String
    var provider: Provider
    @FocusState var isFocused: Bool
    
    @State private var showPopover: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TextField(placeHolder, text: $prompt, axis: .vertical)
                .focused($isFocused)
                .padding(6)
                .padding(.leading, 5)
                .lineLimit(10)
                .modifier(RoundedRectangleOverlayModifier(radius: 18))
            #if !os(macOS) && !targetEnvironment(macCatalyst) && !os(visionOS)
                .background(
                    VisualEffect(colorTint: colorScheme == .dark
                                 ? Color(hex: "050505")
                                 : Color(hex: "FAFAFE"),
                                 colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
                    .cornerRadius(6)
                )
            #endif
            
            if prompt.count > 25 {
                ExpandButton(size: 25) { showPopover.toggle() }
                    .padding(5)
                    .sheet(isPresented: $showPopover) {
                        ExpandedTextField(prompt: $prompt)
                    }
            }
        }
    }
    
    var placeHolder: String {
        "Send a prompt • \(provider.name)"
    }
    
    var leadingPadding: CGFloat {
        return 10
    }
}
