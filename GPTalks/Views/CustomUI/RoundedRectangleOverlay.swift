//
//  CustomViewModifiers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

extension View {
    func roundedRectangleOverlay(radius: CGFloat = 20, opacity: CGFloat = 0.8) -> some View {
        self.modifier(RoundedRectangleOverlayModifier(radius: radius, opacity: opacity))
    }
}


struct RoundedRectangleOverlayModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var radius: CGFloat = 20
    var opacity: CGFloat = 0.8
    
    func body(content: Content) -> some View {
        content
//            .background(
//                RoundedRectangle(cornerRadius: radius, style: style)
//                    .fill(.background.secondary.opacity(0.4))
//            )
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                #if os(macOS)
                    .stroke(.tertiary, lineWidth: 0.6)
                #elseif os(visionOS)
                    .stroke(Color(.quaternaryLabel), lineWidth: 1)
                #else
                    .stroke(colorScheme == .dark ? Color(.tertiarySystemGroupedBackground) : Color(.tertiaryLabel), lineWidth: 1)
                #endif
                    .opacity(opacity)
            )
    }
}

#Preview {
    TextEditor(text: .constant("Hello, World!"))
        .modifier(RoundedRectangleOverlayModifier())
    
}
