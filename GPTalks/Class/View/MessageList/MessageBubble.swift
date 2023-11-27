//
//  MessageBubble.swift
//  ChatGPT
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI

enum MessageType {
    case text
    case edit
}

extension View {
    func bubbleStyle(isMyMessage: Bool, type: MessageType = .text, accentColor: Color = Color(.systemBlue)) -> some View {
        modifier(Bubble(isMyMessage: isMyMessage, type: type, accentColor: accentColor))
    }
}

struct Bubble: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    var isMyMessage: Bool
    var type: MessageType = .text
    var accentColor: Color = Color("greenColor")

    #if os(iOS)
        let radius: CGFloat = 19
        let horizontalPadding: CGFloat = 14
        let verticalPadding: CGFloat = 8
    #else
        let radius: CGFloat = 15
        let horizontalPadding: CGFloat = 11
        let verticalPadding: CGFloat = 8
    #endif

    func body(content: Content) -> some View {
        switch type {
        case .text:
            content
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .background(isMyMessage ? accentColor : Color(.secondarySystemFill))
            #if os(iOS)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: radius, style: .continuous))
            #endif
                .clipShape(RoundedRectangle(cornerRadius: radius))
                .foregroundColor(Color.white)
        case .edit:
            content
                .padding(.horizontal, horizontalPadding - 5)
                .padding(.vertical, verticalPadding)
                .background(.background)
            #if os(iOS)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: radius, style: .continuous))
            #endif
                .clipShape(RoundedRectangle(cornerRadius: radius))
                .foregroundColor(colorScheme == .dark ? Color.primary : Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
    }
}
