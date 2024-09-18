//
//  Bubble.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

extension View {
    func bubbleStyle(compact: Bool = false, radius: CGFloat = 5) -> some View {
        modifier(Bubble(compact: compact, radius: radius))
    }
}

struct Bubble: ViewModifier {
    var compact: Bool
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(7)
#if os(macOS)
            .background(.background.quinary)
#else
            .background(.background.secondary)
#endif
            .cornerRadius(radius)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .font(compact ? .callout : .body)
    }
}
