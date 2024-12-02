//
//  HoverableMessageMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/12/2024.
//

import SwiftUI

struct HoverableMessageMenu<Content: View>: View {
    @State private var isHovering = false
    
    var alignment: Edge.Set
    let content: () -> Content

    var body: some View {
        HStack {
            if alignment == .trailing {
                Image(systemName: "ellipsis.circle")
            }
            
            if isHovering {
                content()
                    .buttonStyle(HoverScaleButtonStyle())
            }
            
            if alignment == .leading {
                Image(systemName: "ellipsis.circle")
            }
        }
        .frame(height: 25)
        .padding(alignment, 300)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}
