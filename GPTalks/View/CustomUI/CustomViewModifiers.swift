//
//  CustomViewModifiers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct RoundedRectangleOverlayModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var radius: CGFloat
    var opacity: CGFloat = 0.8
    var style: RoundedCornerStyle = .continuous
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: style)
                #if os(iOS)
                    .stroke(colorScheme == .dark ? Color(.tertiarySystemGroupedBackground) : Color(.tertiaryLabel), lineWidth: 1)
                #else
                    .stroke(.tertiary, lineWidth: 0.6)
                #endif
                    .opacity(opacity)
            )
    }
}

#Preview {
    TextEditor(text: .constant("Hello, World!"))
        .modifier(RoundedRectangleOverlayModifier(radius: 18))
    
}
