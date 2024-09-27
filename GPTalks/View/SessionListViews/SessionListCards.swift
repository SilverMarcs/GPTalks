//
//  SessionListCards.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI
import SwiftData

struct SessionListCards: View {
    @Environment(\.openWindow) var openWindow
    @Environment(ListStateVM.self) private var listStateVM
    @ObservedObject var config = AppConfig.shared
    var sessionCount: String
    var imageSessionsCount: String
    
    var body: some View {
        Section {
            HStack(spacing: spacing) {
                ListCard(
                    icon: "tray.circle.fill", iconColor: .blue, title: "Chats",
                    count: sessionCount) {
                        handleChatPress()
                    }
                
                ListCard(
                    icon: "photo.circle.fill", iconColor: .indigo, title: "Images",
                    count: imageSessionsCount) {
                        handleImagePress()
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
    
    func handleChatPress() {
        #if os(macOS)
        openWindow(id: "chats")
        #else
        listStateVM.state = .chats
        #endif
    }
    
    func handleImagePress() {
        #if os(macOS)
        openWindow(id: "images")
        #else
        listStateVM.state = .images
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

//#Preview {
//    SessionListCards(sessionCount: "5", imageSessionsCount: "?")
//        .environment(ChatSessionVM())
//}
