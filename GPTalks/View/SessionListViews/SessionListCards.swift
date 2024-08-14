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
    var sessionCount: String
    var imageSessionsCount: String
    
    var body: some View {
        Section {
            HStack(spacing: spacing) {
                ListCard(
                    icon: "tray.circle.fill", iconColor: .blue, title: "Chats",
                    count: sessionCount) {
                        sessionVM.state = .chats
                    }
                
                ListCard(
                    icon: "photo.circle.fill", iconColor: .indigo, title: "Images",
                    count: imageSessionsCount) {
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
}

#Preview {
    SessionListCards(sessionCount: "5", imageSessionsCount: "3")
        .environment(SessionVM())
}
