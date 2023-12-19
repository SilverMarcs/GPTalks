//
//  MacOSMessages.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

#if os(macOS)
struct MacOSMessages: View {
    @EnvironmentObject var viewModel: DialogueViewModel

    @ObservedObject var session: DialogueSession

    @State private var previousContent: String?
    @State private var isUserScrolling = false
    @State private var previousCount: Int = 0
    @State private var contentChangeTimer: Timer? = nil

    var body: some View {
        ScrollViewReader { proxy in
            List {
                VStack {
                    ConversationView(session: session)
                }
                .id("bottomID")
            }
            .background(.background)
            .navigationTitle(session.title)
            .navigationSubtitle(session.configuration.model.name)
            .toolbar {
                ToolbarItems(session: session)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomInputView(
                    session: session
                )
                .background(.bar)
            }
            .onAppear {
                scrollToBottom(proxy: proxy, animated: false)
            }
            .onChange(of: session.conversations.last?.content) {
                if session.conversations.last?.content != previousContent && !isUserScrolling {
                    scrollToBottom(proxy: proxy, animated: false)
                }
                previousContent = session.conversations.last?.content

                contentChangeTimer?.invalidate()
                contentChangeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    isUserScrolling = false
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                isUserScrolling = true
            }
            .onChange(of: session.conversations.count) {
                if session.conversations.count > previousCount {
                    scrollToBottom(proxy: proxy)
                }
                previousCount = session.conversations.count
            }
            .onChange(of: session.input) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: session.resetMarker) {
                if (session.resetMarker == session.conversations.count - 1) || (session.resetMarker == nil) {
                    scrollToBottom(proxy: proxy)
                }
            }
        }
    }
}
#endif
