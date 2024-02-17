//
//  MessageBubble.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI

extension View {
    func bubbleStyle(isMyMessage: Bool, compact: Bool = false, accentColor: Color = Color(.systemBlue)) -> some View {
        modifier(Bubble(isMyMessage: isMyMessage, compact: compact, accentColor: .accentColor))
    }
}

struct Bubble: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    var isMyMessage: Bool
    var compact: Bool = false
    var accentColor: Color = .init("greenColor")

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
        #if os(visionOS)
            .background(.background.secondary)
        #else
            .background(isMyMessage ? accentColor : bubbleBackground)
        #endif
            .cornerRadius(radius)
            .foregroundColor(isMyMessage ? Color.white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .font(compact ? .caption : .body)
//        #if os(iOS)
//            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: radius, style: .continuous))
//        #endif
    }

    private var radius: CGFloat {
        #if os(macOS)
            15
        #else
            18
        #endif
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
            9
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
            5
        } else {
            8
        }
        #endif
    }

    private var bubbleBackground: Color {
        #if os(macOS)
            if colorScheme == .dark {
                return Color("bubbleDark")
            } else {
                return Color(.secondarySystemFill)
            }
        #else
            return Color(.secondarySystemFill)
        #endif
    }
}
