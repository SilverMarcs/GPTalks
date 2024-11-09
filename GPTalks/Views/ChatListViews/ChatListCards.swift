//
//  ChatListCards.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI
import SwiftData

struct ChatListCards: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(SettingsVM.self) private var listStateVM
    @ObservedObject var config = AppConfig.shared
    var sessionCount: String
    var imageSessionsCount: String
    
    var body: some View {
        #if os(macOS)
        content
            .listRowInsets(EdgeInsets(top: spacing - 1, leading: -5, bottom: spacing + 0.5, trailing: -5))
        #else
        Section {
            content
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listSectionSpacing(15)
        #endif
    }
    
    var content: some View {
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
    }
    
    func handleChatPress() {
        #if os(macOS)
        openWindow(id: "chats")
        if config.onlyOneWindow {
            dismissWindow(id: "images")
        }
        #else
        listStateVM.state = .chats
        #endif
    }
    
    func handleImagePress() {
        #if os(macOS)
        openWindow(id: "images")
        if config.onlyOneWindow {
            dismissWindow(id: "chats")
        }
        #else
        listStateVM.state = .images
        #endif
    }
    
    private var spacing: CGFloat {
        #if os(macOS)
        return 8
        #else
        return 13
        #endif
    }
}

#Preview {
    ChatListCards(sessionCount: "5", imageSessionsCount: "?")
        .environment(ChatVM(modelContext: DatabaseService.shared.container.mainContext))
}
