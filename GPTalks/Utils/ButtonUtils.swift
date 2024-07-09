//
//  ButtonUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct HoverProminentPlain: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        IconButtonStyleView(configuration: configuration)
    }
}

private struct IconButtonStyleView: View {
    let configuration: ButtonStyle.Configuration
    @State private var isHovering = false
    
    var body: some View {
        configuration.label
            .labelStyle(.iconOnly)
            .foregroundStyle(isHovering ? .primary : .secondary)
            .contentShape(Rectangle())
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

import SwiftUI

struct HoverSquareBackgroundStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    @State private var isHovering = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.iconOnly)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovering ? Color.gray.opacity(0.2) : Color.clear)
            )
            .contentShape(Rectangle())
            .onHover { hovering in
                isHovering = hovering
            }
            .foregroundColor(isEnabled ? .primary : .secondary)
    }
}

