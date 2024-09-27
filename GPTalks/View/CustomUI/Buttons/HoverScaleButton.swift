//
//  HoverScaleButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/08/2024.
//

import SwiftUI

struct HoverScaleButton: View {
    let icon: String // SF Symbol name
    let label: String
    let action: () -> Void
    @State var hovering = false

    var body: some View {
        Button(action: {
            action()
        }) {
            Label(label, systemImage: icon)
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .symbolEffect(.scale.up, isActive: hovering)
    }
}
