//
//  ThreadList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData

struct ThreadList: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isQuick) var isQuick
    
    @Bindable var chat: Chat
    
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Environment(\.modelContext) var modelContext
    @Environment(ChatVM.self) private var chatVM
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(chat.threads, id: \.self) { thread in
                    ThreadView(thread: thread)
#if os(iOS)
                        .opacity(0.9)
#endif
                }
                .listRowSeparator(.hidden)
                
                ErrorMessageView(message: $chat.errorMessage)
                    .listRowSeparator(.hidden)
                    .transaction { $0.animation = nil }
                
                Color.clear
                    .transaction { $0.animation = nil }
                    .id(String.bottomID)
                    .listRowSeparator(.hidden)
            }
            .task {
                chat.proxy = proxy
                
#if os(macOS)
                scrollToBottom(proxy: proxy, animated: false)
#endif
                
                scrollToBottom(proxy: proxy, delay: 0.2)
            }
            .toolbar {
                ThreadListToolbar(chat: chat)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isQuick {
                    ChatInputView(chat: chat)
                }
            }
            .onChange(of: chat.inputManager.prompt) {
                if chat.inputManager.state == .normal {
                    scrollToBottom(proxy: proxy)
                }
            }

            .onDrop(of: [.item], isTargeted: nil) { providers in
                chat.inputManager.handleDrop(providers)
            }
            .navigationTitle(navTitle)
            #if os(macOS)
            .navigationSubtitle("\(chat.config.systemPrompt.prefix(70))")
            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                if chat.isReplying {  // TODO: use isstreamong here.
                    chat.hasUserScrolled = true
                }
            }
            #else
            .listStyle(.plain)
            .toolbarTitleDisplayMode(.inline)
            .onScrollPhaseChange { oldPhase, newPhase in  // this sint working on macos
                if newPhase == .tracking || newPhase.isScrolling {
                    chat.hasUserScrolled = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { _ in
                scrollToBottom(proxy: proxy, delay: 0.1)
            }
            #if !os(visionOS)
            .scrollDismissesKeyboard(.immediately)
            #endif
            #endif
        }
    }
    
    var navTitle: String {
        horizontalSizeClass == .compact ? chat.config.model.name : chat.title
    }
}

#Preview {
    ThreadList(chat: .mockChat)
        .environment(ChatVM.mockSessionVM)
}
