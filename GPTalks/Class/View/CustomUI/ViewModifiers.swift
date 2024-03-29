//
//  ViewModifiers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/02/2024.
//

import SwiftUI

struct CustomImageViewModifier: ViewModifier {
    let padding: CGFloat
    let imageSize: CGFloat

    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .padding(padding)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .background(Color.gray.opacity(0.2))
            .clipShape(Circle())
            .frame(width: imageSize, height: imageSize)
    }
}

struct RoundedRectangleOverlayModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var radius: CGFloat
    var opacity: CGFloat = 0.8
    
    init(radius: CGFloat = 18, opacity: CGFloat = 0.6) {
        self.radius = radius
        self.opacity = opacity
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                #if os(iOS)
                    .stroke(colorScheme == .dark ? Color(.tertiarySystemGroupedBackground) : Color(.tertiaryLabel), lineWidth: 1)
//                    .opacity(colorScheme == .dark ? opacity : 0.5)
                #else
                    .stroke(.tertiary, lineWidth: 0.6)
                #endif
                    .opacity(opacity)
            )
    }
}

struct ContextMenuModifier: ViewModifier {
    @Binding var isHovered: Bool
    
    func body(content: Content) -> some View {
        content
            .bubbleStyle(isMyMessage: false)
            .roundedRectangleOverlay(opacity: 0.5)
            .shadow(radius: 2, y: 1)
            .labelStyle(.iconOnly)
            .opacity(isHovered ? 1 : 0)
            .transition(.opacity)
            .animation(.easeOut(duration:0.15), value: isHovered)
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}

extension View {
    func roundedRectangleOverlay(radius: CGFloat = 18, opacity: CGFloat = 0.8) -> some View {
        self.modifier(RoundedRectangleOverlayModifier(radius: radius, opacity: opacity))
    }
    
    func inputImageStyle(padding: CGFloat, imageSize: CGFloat) -> some View {
           self.modifier(CustomImageViewModifier(padding: padding, imageSize: imageSize))
       }
    
    func contextMenuModifier(isHovered: Binding<Bool>) -> some View {
        self.modifier(ContextMenuModifier(isHovered: isHovered))
    }
    
    func customBorder(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
