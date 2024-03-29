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
    var radius: CGFloat
    var opacity: CGFloat = 0.8
    
    init(radius: CGFloat = 18, opacity: CGFloat = 0.6) {
        self.radius = radius
        self.opacity = opacity
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                #if os(iOS)
                    .stroke(colorScheme == .dark ? Color(.tertiarySystemGroupedBackground) : Color(.tertiaryLabel), lineWidth: 1)
                    .opacity(colorScheme == .dark ? 0.8 : 0.5)
                #else
                    .stroke(.tertiary, lineWidth: 0.6)
                    .opacity(opacity)
                #endif
            )
    }
}

// Extension to make it easier to apply the modifier
extension View {
    func roundedRectangleOverlay(radius: CGFloat = 18, opacity: CGFloat = 0.8) -> some View {
        self.modifier(RoundedRectangleOverlayModifier(radius: radius, opacity: opacity))
    }
}
