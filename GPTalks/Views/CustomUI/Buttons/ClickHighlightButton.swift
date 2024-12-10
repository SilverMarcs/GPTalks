//
//  ExternalLinkButtonStyle.swift
//  GPTalks
//
//  Created by Zabir Raihan on 11/10/2024.
//

import SwiftUI

struct ClickHighlightButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(10)
            .background(configuration.isPressed ? Color(.tertiarySystemFill): Color(.clear))
            .contentShape(Rectangle())
            .padding(-10)
    }
}

extension ButtonStyle where Self == ClickHighlightButton {
    static var clickHighlight: ClickHighlightButton {
        ClickHighlightButton()
    }
}
