//
//  ListCard.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI

struct ListCard: View {
    var icon: String
    var iconColor: Color
    var title: String
    var count: String
    var action: () -> Void = {}
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading, spacing: 6) {
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
                    .opacity(0.8)
                    .padding(.leading, 2)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 8)
            .background(.quaternary.opacity(0.8))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
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
