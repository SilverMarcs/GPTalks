//
//  PrimaryBorderedButtonStyle.swift
//  GPTalks
//
//  Created by Zabir Raihan on 01/12/2024.
//

import SwiftUI

struct PrimaryBorderedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .font(.callout)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.secondary, lineWidth: 1)
            )
            .contentShape(Rectangle())
    }
}

// Extension to make it easier to use the custom style
extension ButtonStyle where Self == PrimaryBorderedButtonStyle {
    static var primaryBordered: PrimaryBorderedButtonStyle {
        PrimaryBorderedButtonStyle()
    }
}
