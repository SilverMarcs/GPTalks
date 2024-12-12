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
    @Environment(\.modelContext) var modelContext
    @Environment(ChatVM.self) private var chatVM
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Bindable var chat: Chat
    
    @State private var numberOfMessagesToShow = 2
    @State private var colorViewHeight: CGFloat = 0 // Initial height
    
    var body: some View {
        ScrollViewReader { proxy in
            content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if chat.status != .quick {
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
                if chatVM.searchText.isEmpty {
                    scrollToBottom(proxy: proxy, animated: false)
                }
                onAppearStuff(proxy: proxy)
            }
            .pasteHandler(chat: chat)
            .navigationSubtitle("\(chat.config.model.name) • \(chat.config.systemPrompt.prefix(70))")
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
        if !chatVM.searchText.isEmpty {
            numberOfMessagesToShow = chat.currentThread.count
        }
        
        if chatVM.searchText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                #if os(macOS)
                scrollToBottom(proxy: proxy, animated: false)
                #else
                scrollToBottom(proxy: proxy, delay: 0.3)
                #endif
//                if config.markdownProvider == .webview {
//                    scrollToBottom(proxy: proxy, delay: 0.3)
//                }
            }
        }
    }
    
    var messagesToShow: [MessageGroup] {
        let totalMessages = chat.currentThread.count
        if numberOfMessagesToShow >= totalMessages {
            return chat.currentThread
        } else {
            return Array(chat.currentThread.suffix(numberOfMessagesToShow))
        }
    }
    
    @ViewBuilder
    var content: some View {
        if chat.currentThread.isEmpty {
            EmptyChat(chat: chat)
        } else {
            List {
                ForEach(messagesToShow, id: \.self) { message in
                    MessageView(message: message)
                        .onAppear {
                            if message == messagesToShow.first {
                                loadMoreMessages()
                            }
                        }
                }
                #if os(macOS)
                .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
                #endif
                .listRowSeparator(.hidden)
                
                ErrorMessageView(message: $chat.errorMessage)
                
                resizingColor
                
                Color.clear
                    .frame(height: 1)
                    .transaction { $0.animation = nil }
                    .id(String.bottomID)
                    .listRowSeparator(.hidden)
            }
        }
    }
    
    private func loadMoreMessages() {
        let totalMessages = chat.currentThread.count
        if numberOfMessagesToShow <= totalMessages {
            numberOfMessagesToShow += 2
        }
    }
    
    var resizingColor: some View {
        Color.clear
            .frame(height: colorViewHeight)
            .listRowSeparator(.hidden)
            .onChange(of: chat.isReplying) {
                if chat.isReplying {
                    colorViewHeight = 475
                }
            }
            .onChange(of: config.hasUserScrolled) {
                if config.hasUserScrolled {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        colorViewHeight = 0
                    }
                }
            }
    }
}

#Preview {
    ChatDetail(chat: .mockChat)
        .environment(ChatVM.mockChatVM)
}
