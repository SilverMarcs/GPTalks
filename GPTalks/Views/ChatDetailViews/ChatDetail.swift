//
//  ChatDetail.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import TipKit

struct ChatDetail: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isQuick) var isQuick
    @Environment(\.modelContext) var modelContext
    @Environment(ChatVM.self) private var chatVM
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Bindable var chat: Chat
    
    @State private var showingAllMessages = false
    
    var body: some View {
        ScrollViewReader { proxy in
            content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isQuick {
                    ChatInputView(chat: chat)
                }
            }
            .toolbar {
                ChatToolbar(chat: chat)
            }
            .onDrop(of: [.item], isTargeted: nil) { providers in
                chat.inputManager.handleDrop(providers)
            }
            .navigationTitle(horizontalSizeClass == .compact ? chat.config.model.name : chat.title)
            .toolbarTitleMenu {
                Section(chat.title) {
                    Button("Tokens: \(String(format: "%.2fK", Double(chat.totalTokens) / 1000.0))") { }
                }
            }
            #if os(macOS)
            .onAppear {
                scrollToBottom(proxy: proxy, animated: false)
                onAppearStuff(proxy: proxy)
            }
            .pasteHandler(chat: chat)
            .navigationSubtitle("\(chat.config.systemPrompt.prefix(70))")
            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                config.hasUserScrolled = true
            }
            #else
            .task {
                scrollToBottom(proxy: proxy, delay: 0.3)
                onAppearStuff(proxy: proxy)
            }
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
    
    func onAppearStuff(proxy: ScrollViewProxy) {
        config.hasUserScrolled = false
        config.proxy = proxy
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showingAllMessages = true
            #if os(macOS)
            scrollToBottom(proxy: proxy, animated: false)
            #else
            scrollToBottom(proxy: proxy, delay: 0.3)
            #endif
            scrollToBottom(proxy: proxy, delay: 0.3)
        }
    }
    
    var messagesToShow: [MessageGroup] {
        if showingAllMessages {
            return chat.messages
        } else {
            return Array(chat.messages.suffix(2))
        }
    }
    
    @ViewBuilder
    var content: some View {
        if chat.messages.isEmpty {
            EmptyChat(chat: chat)
        } else {
            List {
                if !showingAllMessages && chat.messages.count > 2 {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                }
                
                ForEach(messagesToShow, id: \.self) { message in
                    MessageView(message: message)
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
}

#Preview {
    ChatDetail(chat: .mockChat)
        .environment(ChatVM.mockChatVM)
}
