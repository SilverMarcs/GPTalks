//
//  Bubble.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

extension View {
    func bubbleStyle(compact: Bool = false, radius: CGFloat = 5, accentColor: Color = Color(.systemBlue)) -> some View {
        modifier(Bubble(compact: compact, radius: radius, accentColor: .accentColor))
    }
}

struct Bubble: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    var compact: Bool = false
    var radius: CGFloat = 15
    var accentColor: Color = .init("greenColor")

    func body(content: Content) -> some View {
        content
            .padding(5)
        #if os(macOS) || targetEnvironment(macCatalyst)
            .background(.background.quinary)
        #else
            .background(.background.secondary)
        #endif
            .cornerRadius(radius)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .font(compact ? .callout : .body)
    }

    private var horizontalPadding: CGFloat {
        #if os(macOS)
        if compact {
            8
        } else {
            11
        }
        #else
        if compact {
            10
        } else {
            13
        }
        #endif
    }

    private var verticalPadding: CGFloat {
        #if os(macOS)
        if compact {
            4
        } else {
            8
        }
        #else
        if compact {
            6
        } else {
            8
        }
        #endif
    }
}
