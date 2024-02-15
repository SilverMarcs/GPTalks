//
//  MessageBubble.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI

enum MessageType {
    case text
    case edit
}

extension View {
    func bubbleStyle(isMyMessage: Bool, accentColor: Color = Color(.systemBlue)) -> some View {
//        modifier(Bubble(isMyMessage: isMyMessage, accentColor: accentColor))
        modifier(Bubble(isMyMessage: isMyMessage, accentColor: .accentColor))
    }
}

struct Bubble: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    var isMyMessage: Bool
    var type: MessageType = .text
    var accentColor: Color = Color("greenColor")
    
    #if os(macOS)
        let radius: CGFloat = 15
        let horizontalPadding: CGFloat = 11
        let verticalPadding: CGFloat = 8
    #else
        let radius: CGFloat = 18
        let horizontalPadding: CGFloat = 14
        let verticalPadding: CGFloat = 8
    #endif
    
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
        #if os(iOS)
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: radius, style: .continuous))
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

