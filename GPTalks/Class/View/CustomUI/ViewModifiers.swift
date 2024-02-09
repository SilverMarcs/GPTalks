//
//  ViewModifiers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/02/2024.
//

import SwiftUI


// Define the custom view modifier
struct RoundedRectangleOverlayModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                #if os(iOS)
                    .stroke(colorScheme == .dark ? Color(.tertiarySystemGroupedBackground) : Color(.tertiaryLabel), lineWidth: 1)
                    .opacity(colorScheme == .dark ? 0.8 : 0.5)
                #else
                    .stroke(.tertiary, lineWidth: 0.6)
                    .opacity(0.8)
                #endif
            )
    }
}

// Extension to make it easier to apply the modifier
extension View {
    func roundedRectangleOverlay() -> some View {
        self.modifier(RoundedRectangleOverlayModifier())
    }
}
