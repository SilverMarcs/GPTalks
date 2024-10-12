//
//  ConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData

struct ConversationList: View {
    @Environment(\.isQuick) var isQuick
    
    @Bindable var session: ChatSession
    
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Environment(\.modelContext) var modelContext
    @Environment(ChatSessionVM.self) private var sessionVM
    
    @State private var hasUserScrolled = false
    
    var body: some View {
        ScrollViewReader { proxy in
            Group {
                if session.groups.isEmpty {
                    EmptyConversationList(session: session)
                } else {
                    switch config.conversationListStyle {
                    case .list:
                        listView
                    case .scrollview:
                        vStackView
                    }
                }
            }
            .onChange(of: sessionVM.chatSelections) {
                Task {
                    await sessionVM.chatSelections.first?.refreshTokens()
                }
                
                #if os(macOS)
                scrollToBottom(proxy: proxy, delay: 0.2)
                #endif
                session.proxy = proxy
                scrollToBottom(proxy: proxy, delay: 0.4)
            }
            .toolbar { ConversationListToolbar(session: session) }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isQuick {
                    ChatInputView(session: session)
                }
            }
//            .safeAreaInset(edge: .top, spacing: 0) {
//                 if config.showStatusBar {
//                     ConversationStatusBar(session: session)
//                 }
//             }
            .onChange(of: session.groups.last?.activeConversation.content) {
                if !hasUserScrolled && session.isStreaming {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.groups.last?.activeConversation.toolCalls) {
                if !hasUserScrolled && session.isStreaming {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.groups.last?.activeConversation.toolResponse) {
                if !hasUserScrolled && session.isStreaming {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.isStreaming) {
                if !session.isStreaming  {
                    if !hasUserScrolled {
                        scrollToBottom(proxy: proxy)
                    }
                    hasUserScrolled = false
                }
            }
            .onChange(of: session.inputManager.prompt) {
                if session.inputManager.state == .normal {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onDrop(of: session.config.provider.type.supportedFileTypes, isTargeted: nil) { providers in
                session.inputManager.handleDrop(providers, supportedTypes: session.config.provider.type.supportedFileTypes)
            }
        #if os(macOS)
            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                if config.conversationListStyle == .list && session.isReplying {
                    hasUserScrolled = true
                }
            }
        #else
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { _ in
                scrollToBottom(proxy: proxy, delay: 0.1)
            }
        #endif
        }
                #if os(macOS)
                .navigationSubtitle("Tokens: \(session.tokenCount.formatToK()) • \(session.config.systemPrompt.prefix(50))")
                .navigationTitle(session.title)
                #else
                .toolbarTitleDisplayMode(.inline)
                .navigationTitle(session.config.model.name)
                .toolbarTitleMenu {
                    Section("\(session.tokenCount.formatToK()) tokens") {
                        Button {
                            Task {
                                await session.refreshTokens()
                            }
                        } label: {
                            Label("Refresh Tokens", systemImage: "arrow.clockwise")
                        }
                    }
                }
                #if !os(visionOS)
                .scrollDismissesKeyboard(.immediately)
                #endif
                #endif
    }
    
    var content: some View {
        ScrollViewReader { proxy in
            Group {
                if session.groups.isEmpty {
                    EmptyConversationList(session: session)
                } else {
                    switch config.conversationListStyle {
                    case .list:
                        listView
                    case .scrollview:
                        vStackView
                    }
                }
            }
            .onChange(of: sessionVM.chatSelections) {
                Task {
                    await sessionVM.chatSelections.first?.refreshTokens()
                }
                
                #if os(macOS)
                scrollToBottom(proxy: proxy, delay: 0.2)
                #endif
                session.proxy = proxy
                scrollToBottom(proxy: proxy, delay: 0.4)
            }
            .toolbar { ConversationListToolbar(session: session) }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isQuick {
                    ChatInputView(session: session)
                }
            }
//            .safeAreaInset(edge: .top, spacing: 0) {
//                 if config.showStatusBar {
//                     ConversationStatusBar(session: session)
//                 }
//             }
            .onChange(of: session.groups.last?.activeConversation.content) {
                if !hasUserScrolled && session.isStreaming {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.groups.last?.activeConversation.toolCalls) {
                if !hasUserScrolled && session.isStreaming {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.groups.last?.activeConversation.toolResponse) {
                if !hasUserScrolled && session.isStreaming {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.isStreaming) {
                if !session.isStreaming  {
                    if !hasUserScrolled {
                        scrollToBottom(proxy: proxy)
                    }
                    hasUserScrolled = false
                }
            }
            .onChange(of: session.inputManager.prompt) {
                if session.inputManager.state == .normal {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onDrop(of: session.config.provider.type.supportedFileTypes, isTargeted: nil) { providers in
                session.inputManager.handleDrop(providers, supportedTypes: session.config.provider.type.supportedFileTypes)
            }
        #if os(macOS)
            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                if config.conversationListStyle == .list && session.isReplying {
                    hasUserScrolled = true
                }
            }
        #else
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { _ in
                scrollToBottom(proxy: proxy, delay: 0.1)
            }
        #endif
        }
    }
    
    var vStackView: some View  {
        ScrollView {
            VStack(spacing: spacing) {
                ForEach(session.groups, id: \.self) { group in
                    ConversationGroupView(group: group)
                }

                ErrorMessageView(session: session)
                
                colorSpacer
            }
            .padding()
            .padding(.top, -5)
        }
        .onScrollPhaseChange { oldPhase, newPhase in
            if newPhase == .interacting {
                hasUserScrolled = true
            }
        }
        .scrollContentBackground(.visible)
    }
    
    var listView: some View {
        List {
            VStack(spacing: 3) {
                ForEach(session.groups) { group in
                    ConversationGroupView(group: group)
                }
                .transaction { $0.animation = nil }

                ErrorMessageView(session: session)
            }
            .listRowSeparator(.hidden)
            .transaction { $0.animation = nil }
            
            Color.clear
                .id(String.bottomID)
                .listRowSeparator(.hidden)
                .transaction { $0.animation = nil }
        }
    }
    
    var colorSpacer: some View {
        Color.clear
            .frame(height: spacerHeight)
            .id(String.bottomID)
    }
    
    var spacerHeight: CGFloat {
        #if os(macOS)
        if config.markdownProvider == .webview {
            20
        } else {
            1
        }
        #else
        10
        #endif
    }
    
    var spacing: CGFloat {
        #if os(macOS)
        0
        #else
        15
        #endif
    }
}

#Preview {
    ConversationList(session: .mockChatSession)
        .environment(ChatSessionVM.mockSessionVM)
}
