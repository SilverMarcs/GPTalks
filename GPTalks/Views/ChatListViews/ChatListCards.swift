//
//  ChatListCards.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI

struct ChatListCards: View {
    @Environment(\.isSearching) private var isSearching
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(ChatVM.self) var chatVM
    @Environment(SettingsVM.self) private var settingsVM
    
    @ObservedObject var config = AppConfig.shared
    
    var source: Source
    var chatCount: String
    var imageSessionsCount: String
    
    @State private var isFlashing = false

    var body: some View {
        #if os(macOS)
        content
            .listRowInsets(EdgeInsets(top: spacing, leading: -5, bottom: spacing, trailing: -5))
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
                icon: chatVM.statusFilter.systemImageName, iconColor: chatVM.statusFilter.iconColor, title: isSearching ? "Searching" : chatVM.statusFilter.name,
                count: chatCount) {
                    handleChatPress()
                }
                .symbolEffect(.bounce.down, options: .speed(0.1), isActive: config.hasUsedChatStatusFilter == false)
                .contentTransition(.symbolEffect(.replace.offUp))
                .disabled(isSearching)
                .onAppear {
                    if !config.hasUsedChatStatusFilter {
                        isFlashing = true
                    }
                }
                .onChange(of: config.hasUsedChatStatusFilter) {
                    if config.hasUsedChatStatusFilter {
                        isFlashing = false
                    }
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
        switch source {
        case .chatlist:
            cycleChatStatus()
        case .imagelist:
            #if os(macOS)
            openWindow(id: WindowID.chats)
            if config.onlyOneWindow {
                dismissWindow(id: "images")
            }
            #else
            settingsVM.listState = .chats
            #endif
        }
    }
    
    func cycleChatStatus() {
        config.hasUsedChatStatusFilter = true
        let statusesToCycle = ChatStatus.allCases.filter { $0 != .quick && $0 != .temporary }
        
        guard let currentStatusIndex = statusesToCycle.firstIndex(of: chatVM.statusFilter) else {
            return
        }
        
        let nextStatusIndex = (currentStatusIndex + 1) % statusesToCycle.count
        chatVM.statusFilter = statusesToCycle[nextStatusIndex]
    }

    
    func handleImagePress() {
        #if os(macOS)
        openWindow(id: WindowID.images)
        if config.onlyOneWindow {
            dismissWindow(id: "chats")
        }
        #else
        settingsVM.listState = .images
        #endif
    }
    
    private var spacing: CGFloat {
        #if os(macOS)
        return 8
        #else
        return 13
        #endif
    }
    
    private var radius: CGFloat {
        #if os(macOS)
        return 7
        #else
        return 10
        #endif
    }
}

#Preview {
    ChatListCards(source: .chatlist, chatCount: "5", imageSessionsCount: "?")
        .environment(ChatVM())
}
