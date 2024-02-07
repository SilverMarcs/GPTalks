//
//  ViewModifiers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/02/2024.
//

import SwiftUI


// Define the custom view modifier
struct RoundedRectangleOverlayModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.tertiary, lineWidth: 0.6)
                    .opacity(0.8)
            )
    }
}

// Extension to make it easier to apply the modifier
extension View {
    func roundedRectangleOverlay() -> some View {
        self.modifier(RoundedRectangleOverlayModifier())
    }
}
