//
//  ChatDetail.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import TipKit
import SwiftData

struct ChatDetail: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isQuick) var isQuick
    @Environment(\.modelContext) var modelContext
    @Environment(ChatVM.self) private var chatVM
    @ObservedObject var config: AppConfig = AppConfig.shared
    @FocusState var isFocused: FocusedField?
    
    @Bindable var chat: Chat
    
    var body: some View {
        ScrollViewReader { proxy in
            content
            .toolbar {
                ChatToolbar(chat: chat)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isQuick {
                    ChatInputView(chat: chat)
                }
            }
            .onDrop(of: [.item], isTargeted: nil) { providers in
                chat.inputManager.handleDrop(providers)
            }
            .navigationTitle(navTitle)
            .toolbarTitleMenu {
                Section(chat.title) {
                    Button("Tokens: \(String(format: "%.2fK", Double(chat.totalTokens) / 1000.0))") { }
                }
            }
            .task(id: chatVM.selections) {
                config.hasUserScrolled = false
                config.proxy = proxy
                #if os(macOS)
                scrollToBottom(proxy: proxy, animated: false)
                #else
                scrollToBottom(proxy: proxy, delay: 0.3)
                #endif
                scrollToBottom(proxy: proxy, delay: 0.2)
            }
            #if os(macOS)
            .navigationSubtitle("\(chat.config.systemPrompt.prefix(70))")
            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                if chat.isReplying {
                    config.hasUserScrolled = true
                }
            }
            #else
            .listStyle(.plain)
            .toolbarTitleDisplayMode(.inline)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { _ in
                scrollToBottom(proxy: proxy, delay: 0.1)
            }
            #if !os(visionOS)
            .scrollDismissesKeyboard(.immediately)
            #endif
            #endif
        }
    }
    
    @ViewBuilder
    var content: some View {
        if chat.messages.isEmpty && config.markdownProvider == .webview {
            EmptyChat(chat: chat)
        } else {
            List {
                ForEach(chat.messages, id: \.self) { message in
                    MessageView(message: message)
                        #if os(iOS)
                        .opacity(0.9)
                        #endif
                }
                .listRowSeparator(.hidden)
                
                ErrorMessageView(message: $chat.errorMessage)
                
                Color.clear
                    .transaction { $0.animation = nil }
                    .id(String.bottomID)
                    .listRowSeparator(.hidden)
            }
        }
    }
    
    var navTitle: String {
        horizontalSizeClass == .compact ? chat.config.model.name : chat.title
    }
}

#Preview {
    ChatDetail(chat: .mockChat)
        .environment(ChatVM.mockChatVM)
}
