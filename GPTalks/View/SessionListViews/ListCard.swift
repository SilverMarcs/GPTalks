//
//  ListCard.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI

struct ListCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var icon: String
    var iconColor: Color
    var title: String
    var count: String
    var action: () -> Void = {}
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading, spacing: spacing) {
                HStack {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundStyle(.white, iconColor)

                    Spacer()
                    
                    Text(count)
                        .contentTransition(.numericText())
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Text(title)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .opacity(0.9)
                    .padding(.leading, 2)
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            #if os(macOS)
            .background(.quaternary.opacity(0.8))
            #else
            .background(colorScheme == .dark
                        ? isIPadOS()
                            ? AnyShapeStyle(.background.tertiary)
                            : AnyShapeStyle(.background.secondary)
                        : AnyShapeStyle(.background))
            #endif
            .cornerRadius(radius)
        }
        .buttonStyle(.plain)
    }
    
    private var radius: CGFloat {
    #if os(macOS)
        return 7
    #else
        return 10
    #endif
    }
    
    private var verticalPadding: CGFloat {
        #if os(macOS)
        return 5
        #else
        return 7
        #endif
    }
    
    private var horizontalPadding: CGFloat {
        #if os(macOS)
        return 8
        #else
        return 10
        #endif
    }
    
    private var spacing: CGFloat {
        #if os(macOS)
        return 6
        #else
        return 10
        #endif
    }
}

#Preview {
    HStack {
        ListCard(icon: "tray.circle.fill", iconColor: .blue, title: "Chats", count: String(20))
        ListCard(icon: "photo.circle.fill", iconColor: .cyan, title: "Images", count: "0") {
            
        }
    }
    .background(.clear)
    .frame(width: 280, height: 100)
    .padding()
}
