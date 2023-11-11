//
//  MessageBubble.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/16.
//


import SwiftUI

extension View {
    func bubbleStyle(isMyMessage: Bool, type: MessageType = .text, service: AIProvider = .openAI) -> some View {
        modifier(Bubble(isMyMessage: isMyMessage, type: type, service: service))
    }
}

struct Bubble: ViewModifier {
    
    var isMyMessage: Bool
    var type: MessageType = .text
    var service: AIProvider = .openAI
    
    #if os(iOS)
    let radius: CGFloat = 19
    let horizontalPadding: CGFloat = 11
    let verticalPadding: CGFloat = 8
    #else
    let radius: CGFloat = 15
    let horizontalPadding: CGFloat = 11
    let verticalPadding: CGFloat = 8
    #endif
    
    
    func body(content: Content) -> some View {
       switch type {
       case .text, .textEdit:
           let backgroundColor = type == .textEdit && isMyMessage ? Color(.darkGray) : isMyMessage ? userMessageBackgroundColor : replyBackgroundColor
           let foregroundColor = isMyMessage ? Color.white : Color.primary

           content
               .padding(.horizontal, horizontalPadding)
               .padding(.vertical, verticalPadding)
               .background(backgroundColor)
               #if os(iOS)
               .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: radius, style: .continuous))
               #endif
               .clipShape(RoundedRectangle(cornerRadius: radius))
               .foregroundColor(foregroundColor)
       }
    }

    
    private var editingBackgroundColor: Color {
        Color(.darkGray)
    }
    
    private var userMessageBackgroundColor: Color {
        switch service {
        case .openAI:
            return Color("greenColor")
        case .openRouter:
            return Color("purpleColor")
        case .pAI:
            return Color("orangeColor")
        }
    }
    
    private var replyBackgroundColor: Color {
#if os(macOS)
        colorScheme == .light ? Color(hexadecimal: "#e9e9eb") : Color(hexadecimal: "#323233")
#else
        colorScheme == .light ? Color(hexadecimal: "#e9e9eb") : Color(hexadecimal: "#262529")
#endif
    }
    
    @Environment(\.colorScheme) var colorScheme
}
