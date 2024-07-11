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
            .labelStyle(.iconOnly)
            .menuIndicator(.hidden)
            .menuStyle(.borderlessButton)
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

#Preview {
    VStack {
//        Menu {
//            Button("Open") { }
//            Button("Save") { }
//            Button("Close") { }
//        } label: {
//            Label("File", systemImage: "doc")
//        }
//        .menuStyle(SimpleIconOnly())
        
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

