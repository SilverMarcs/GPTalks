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
    
    @Bindable var session: Chat
    
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Environment(\.modelContext) var modelContext
    @Environment(ChatVM.self) private var sessionVM
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(session.threads, id: \.self) { thread in
                    ThreadView(thread: thread)
                        #if os(iOS)
                        .opacity(0.9)
                        #endif
                }
                .listRowSeparator(.hidden)

                ErrorMessageView(message: $session.errorMessage)
                    .listRowSeparator(.hidden)
                    .transaction { $0.animation = nil }
            
                Color.clear
                    .transaction { $0.animation = nil }
                    .id(String.bottomID)
                    .listRowSeparator(.hidden)
            }
            .task {
                session.proxy = proxy
                
                #if os(macOS)
                scrollToBottom(proxy: proxy, animated: false)
                #endif
                
                scrollToBottom(proxy: proxy, delay: 0.2)
            }
            .toolbar {
                ThreadListToolbar(session: session)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isQuick {
                    ChatInputView(session: session)
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
                if session.isReplying {  // TODO: use isstreamong here.
                    session.hasUserScrolled = true
                }
            }
            #else
            .listStyle(.plain)
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
    ThreadList(session: .mockChat)
        .environment(ChatVM.mockSessionVM)
}
