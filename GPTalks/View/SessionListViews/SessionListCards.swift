//
//  SessionListCards.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI
import SwiftData

struct SessionListCards: View {
    @Environment(SessionVM.self) private var sessionVM
    @Query var sessions: [Session]
    
    var body: some View {
        HStack(spacing: spacing) {
            ListCard(
                icon: "tray.circle.fill", iconColor: .blue, title: "Chats",
                count: String(sessions.count)) {
                    toggleChatCount()
                }
            
            ListCard(
                icon: "photo.circle.fill", iconColor: .cyan, title: "Images",
                count: "0"
            ) {
            }
        }
    }
    
    private var spacing: CGFloat {
        #if os(macOS)
        return 9
        #else
        return 13
        #endif
    }
    
    func toggleChatCount() {
        if sessionVM.chatCount == .max {
            sessionVM.chatCount = 13
        } else {
            sessionVM.chatCount = .max
        }
    }
}

#Preview {
    SessionListCards()
        .environment(SessionVM())
}
