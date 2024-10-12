//
//  ConversationListExtended.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI
import UniformTypeIdentifiers

extension View {
    func applyObservers(proxy: ScrollViewProxy, session: ChatSession, hasUserScrolled: Binding<Bool>) -> some View {
        @ObservedObject var config = AppConfig.shared
        
        return self
            .onChange(of: session.groups.last?.activeConversation.content) {
                if !hasUserScrolled.wrappedValue && session.isStreaming {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.groups.last?.activeConversation.toolCalls) {
                if !hasUserScrolled.wrappedValue && session.isStreaming {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.groups.last?.activeConversation.toolResponse) {
                if !hasUserScrolled.wrappedValue && session.isStreaming {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.isStreaming) {
                if !session.isStreaming  {
                    if !hasUserScrolled.wrappedValue {
                        scrollToBottom(proxy: proxy)
                    }
                    hasUserScrolled.wrappedValue = false
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
                    hasUserScrolled.wrappedValue = true
                }
            }
        #else
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { _ in
                scrollToBottom(proxy: proxy, delay: 0.1)
            }
        #endif
    }
}

struct PlatformSpecificModifiers: ViewModifier {
    let session: ChatSession
    @Binding var hasUserScrolled: Bool
    
    @ViewBuilder
    func body(content: Content) -> some View {
        content
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
}
