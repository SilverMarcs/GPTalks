//
//  MacOSMessages.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

#if os(macOS)
struct MacOSMessages: View {
    @Environment(DialogueViewModel.self) private var viewModel

    var session: DialogueSession

    @State private var previousContent: String?
    @State private var isUserScrolling = false
    @State private var contentChangeTimer: Timer? = nil

    @FocusState var isTextFieldFocused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            List {
                VStack {
                    ForEach(session.conversations) { conversation in
                        ConversationView(session: session, conversation: conversation)
                    }

                    ErrorDescView(session: session)
                }
                .id("bottomID")
            }
            .navigationTitle(session.title)
            .navigationSubtitle("Context: \(session.getMessageCountAfterResetMarker())/\(session.configuration.contextLength)")
            .toolbar {
                ToolbarItems(session: session)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomInputView(
                    session: session,
                    focused: _isTextFieldFocused
                )
                .background(.bar)
            }
            .onChange(of: viewModel.selectedDialogue) {
                isTextFieldFocused = true
                scrollToBottom(proxy: proxy, animated: true, delay: 0.2)
                scrollToBottom(proxy: proxy, animated: true, delay: 0.4)
                scrollToBottom(proxy: proxy, animated: true, delay: 0.8)
            }
            .onChange(of: session.conversations.last?.content) {
                if session.conversations.last?.content != previousContent && !isUserScrolling {
                    scrollToBottom(proxy: proxy, animated: true)
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
            .onChange(of: session.isAddingConversation) {
                scrollToBottom(proxy: proxy, animated: true)
            }
            .onChange(of: session.input) {
                if session.input.contains("\n") || (session.input.count > 105) {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.resetMarker) {
                if session.resetMarker == session.conversations.count - 1 {
                    scrollToBottom(proxy: proxy)
                }
                isTextFieldFocused = true
            }
            .onChange(of: session.errorDesc) {
                scrollToBottom(proxy: proxy, animated: true)
            }
//            Spacer() // enable this to change toolbar color
        }
    }

    private var alternateList: some View {
        // not used for now
        List {
            ForEach(Array(session.conversations.chunked(fromEndInto: 10).enumerated()), id: \.offset) { _, chunk in
                VStack {
                    ForEach(chunk, id: \.self) { conversation in
                        ConversationView(session: session, conversation: conversation)
                    }
                }
                .listRowSeparator(.hidden)
            }

            ErrorDescView(session: session)
                .listRowSeparator(.hidden)

            Spacer()
                .listRowSeparator(.hidden)
                .id("bottomID")
        }
    }
}
#endif
