//
//  ConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData

struct ConversationList: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isQuick) var isQuick
    
    @Bindable var session: ChatSession
    
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Environment(\.modelContext) var modelContext
    @Environment(ChatSessionVM.self) private var sessionVM
    
    @State private var hasUserScrolled = false
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(session.groups, id: \.self) { group in
                    ConversationGroupView(group: group)
                }
                .listRowSeparator(.hidden)

                ErrorMessageView(message: $session.errorMessage)
            
                Color.clear
                    .id(String.bottomID)
                    .listRowSeparator(.hidden)
            }
            #if !os(macOS)
            .listStyle(.plain)
            #endif
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    session.refreshTokens()
                }
                
                session.proxy = proxy
                
                #if os(macOS)
                scrollToBottom(proxy: proxy, animated: false)
                #endif
                
                scrollToBottom(proxy: proxy, delay: 0.2)
            }
            .toolbar {
                ConversationListToolbar(session: session)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isQuick {
                    ChatInputView(session: session)
                }
            }
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
            .onDrop(of: [.item], isTargeted: nil) { providers in
                session.inputManager.handleDrop(providers)
            }
            .navigationTitle(navTitle)
            #if os(macOS)
            .navigationSubtitle("\(session.config.systemPrompt.prefix(70))")
            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                if session.isReplying {
                    hasUserScrolled = true
                }
            }
            #else
            .toolbarTitleDisplayMode(.inline)
            #if !os(visionOS)
            .scrollDismissesKeyboard(.immediately)
            #endif
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { _ in
                scrollToBottom(proxy: proxy, delay: 0.1)
            }
            #endif
        }
    }
    
    var navTitle: String {
        horizontalSizeClass == .compact ? session.config.model.name : session.title
    }
}

#Preview {
    ConversationList(session: .mockChatSession)
        .environment(ChatSessionVM.mockSessionVM)
}
