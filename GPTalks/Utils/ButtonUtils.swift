//
//  ButtonUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct SimpleIconOnly: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .labelStyle(.iconOnly)
            .menuIndicator(.hidden)
            .menuStyle(.borderlessButton)
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

#Preview {
    VStack {
        Menu {
            Button("Open") { }
            Button("Save") { }
            Button("Close") { }
        } label: {
            Label("File", systemImage: "doc")
        }
        .menuStyle(SimpleIconOnly())
    }
    .padding()
    .frame(width: 200)
}

