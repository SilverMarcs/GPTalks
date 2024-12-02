//
//  HoverScaleButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/08/2024.
//

import SwiftUI

struct HoverScaleButtonStyle: ButtonStyle {
    @State private var isHovering = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(.plain)
            .onHover { isHovering = $0 }
            .symbolEffect(.scale.up, isActive: isHovering)
            .labelStyle(.iconOnly)
    }
}

extension ButtonStyle where Self == HoverScaleButtonStyle {
    static var hoverScale: HoverScaleButtonStyle {
        HoverScaleButtonStyle()
    }
}
