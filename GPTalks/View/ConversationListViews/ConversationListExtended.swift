//
//  ConversationListExtended.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI
import UniformTypeIdentifiers

extension View {
    func applyObservers(proxy: ScrollViewProxy, session: Session, hasUserScrolled: Binding<Bool>) -> some View {
        @ObservedObject var config = AppConfig.shared
        
        return self
            .onAppear {
                scrollToBottom(proxy: proxy, delay: 0.4)
            }
            .onChange(of: session.groups.last?.activeConversation.content) {
                if !hasUserScrolled.wrappedValue && session.isStreaming {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.isStreaming) {
                if !session.isStreaming  {
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
                if session.isReplying {
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
    let session: Session
    @Binding var showingInspector: Bool
    @Binding var hasUserScrolled: Bool
    
    @State private var isExportingJSON = false
    @State private var isExportingMarkdown = false
    
    @ViewBuilder
    func body(content: Content) -> some View {
        content
//            .toolbar { ConversationListToolbar(session: session, providers: providers) }
            #if os(macOS)
            .navigationSubtitle("\(session.tokenCount.formatToK()) tokens • \(session.config.systemPrompt.trimmingCharacters(in: .newlines).truncated(to: 45))")
            .navigationTitle(session.title)
            #else
            .onTapGesture { showingInspector = false }
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle(session.config.model.name)
            .toolbarTitleMenu {
                Section("\(session.tokenCount.formatToK()) tokens") {
                    Button {
                        session.refreshTokens()
                    } label: {
                        Label("Refresh Tokens", systemImage: "arrow.clockwise")
                    }
                }
            }
            #if !os(visionOS)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                hasUserScrolled = value > UIScreen.main.bounds.height
            }
            .scrollDismissesKeyboard(.immediately)
            #endif
            #endif
    }
}

func scrollToBottom(proxy: ScrollViewProxy, id: String = .bottomID, anchor: UnitPoint = .bottom, animated: Bool = true, delay: TimeInterval = 0.0) {
    let action = {
        if animated {
            withAnimation {
                proxy.scrollTo(id, anchor: anchor)
            }
        } else {
            proxy.scrollTo(id, anchor: anchor)
        }
    }
    
    if delay > 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
    } else {
        DispatchQueue.main.async(execute: action)
    }
}
