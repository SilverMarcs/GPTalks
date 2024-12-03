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
    
    @State private var showingAllMessages = false
    @State private var colorViewHeight: CGFloat = 1 // Initial height
    
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showingAllMessages = true
            #if os(macOS)
            if chatVM.searchText.isEmpty {
                scrollToBottom(proxy: proxy, animated: false)
            }
            #else
            scrollToBottom(proxy: proxy, delay: 0.3)
            #endif
            if config.markdownProvider == .webview {
                scrollToBottom(proxy: proxy, delay: 0.3)
            }
        }
    }
    
    var messagesToShow: [MessageGroup] {
        if showingAllMessages {
            return chat.currentThread
        } else {
            return Array(chat.currentThread.suffix(2))
        }
    }
    
    @ViewBuilder
    var content: some View {
        if chat.currentThread.isEmpty {
            EmptyChat(chat: chat)
        } else {
            List {
                if !showingAllMessages && chat.currentThread.count > 2 {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                }

                ForEach(messagesToShow, id: \.self) { message in
                    MessageView(message: message)
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
    
    // TODO: dunno how expensive this is
    var resizingColor: some View {
        Color.clear
            .frame(height: colorViewHeight)
            .listRowSeparator(.hidden)
            .onChange(of: chat.isReplying) {
                if chat.isReplying {
                    withAnimation {
                        colorViewHeight = 475
                    }
                } else {
                    // Animate height reduction in small steps
                    let numberOfSteps = 100 // More steps = smoother animation
                    let totalDuration = 0.45 // Total animation duration in seconds
                    let stepDuration = totalDuration / Double(numberOfSteps)
                    let heightDifference = 474.0 // 450 - 1
                    let stepChange = heightDifference / Double(numberOfSteps)
                    
                    for step in 0..<numberOfSteps {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * stepDuration) {
                            withAnimation(.easeIn(duration: stepDuration)) {
                                colorViewHeight = 475 - (stepChange * Double(step + 1))
                            }
                        }
                    }
                }
            }
    }
}

#Preview {
    ChatDetail(chat: .mockChat)
        .environment(ChatVM.mockChatVM)
}
