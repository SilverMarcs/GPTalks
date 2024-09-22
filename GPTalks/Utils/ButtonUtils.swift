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
            .menuStyle(BorderlessButtonMenuStyle())
            .fixedSize()
    }
}

import SwiftUI

struct HoverSquareBackgroundStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    @State private var isHovering = false
    
    let size: CGFloat = 25 // Fixed size for the button
    let imagePadding: CGFloat = 12 // Padding around the image
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.iconOnly)
            .frame(width: size - (imagePadding * 2), height: size - (imagePadding * 2)) // Set frame for image
            .aspectRatio(contentMode: .fit) // Ensure image fits within frame
            .frame(width: size, height: size) // Set overall button size
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

struct TextLeftIconRightLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            Spacer()
            configuration.icon
        }
    }
}

struct ExternalLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(configuration.isPressed ? Color(.tertiarySystemFill): Color(.clear))
            .contentShape(Rectangle())
            .padding(-10)
    }
}

#Preview {
    VStack {
        HStack(spacing: 0) {
            Button {
                print("Button tapped")
            } label: {
                Image(systemName: "paperclip")
            }
            .buttonStyle(HoverSquareBackgroundStyle())
            
            Button {
                print("Button tapped")
            } label: {
                Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
            }
            .buttonStyle(HoverSquareBackgroundStyle())
        }
    }
    .padding()
    .frame(width: 200)
}

