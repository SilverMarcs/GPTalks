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
    @Query var imageSessions: [ImageSession]
    
    var body: some View {
        Section {
            HStack(spacing: spacing) {
                ListCard(
                    icon: "tray.circle.fill", iconColor: .blue, title: "Chats",
                    count: String(sessions.filter { !$0.isQuick }.count)) {
                        toggleChatCount()
                    }
                
                ListCard(
                    icon: "photo.circle.fill", iconColor: .cyan, title: "Images",
                    count: String(imageSessions.count)
                ) {
                    sessionVM.state = .images
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            #if os(macOS)
                .listRowInsets(EdgeInsets(top: 0, leading: -5, bottom: 8, trailing: -5))
            #else
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            #endif
        }
        #if !os(macOS)
        .listSectionSpacing(15)
        #endif
    }
    
    private var spacing: CGFloat {
        #if os(macOS)
        return 9
        #else
        return 13
        #endif
    }
    
    func toggleChatCount() {
        if sessionVM.state == .chats {
            if sessionVM.chatCount == .max {
                sessionVM.chatCount = 12
            } else {
                sessionVM.chatCount = .max
            }
        } else {
            sessionVM.state = .chats
        }
    }
}

#Preview {
    SessionListCards()
        .environment(SessionVM())
}
