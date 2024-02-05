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
                ForEach(Array(session.conversations.chunked(into: 10).enumerated()), id: \.offset) { index, chunk in
                    VStack {
                        ForEach(chunk, id: \.self) { conversation in
                            ConversationView(session: session, conversation: conversation)
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                
                DeleteBtn(proxy: proxy)
                    .opacity(0)
                
                ErrorDescView(session: session)
                    .listRowSeparator(.hidden)
                
                Color.clear
                    .listRowSeparator(.hidden)
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
                    session: session,
                    focused: _isTextFieldFocused
                )
                .background(.bar)
            }
            .onChange(of: viewModel.selectedDialogue) {
                scrollToBottom(proxy: proxy, animated: true, delay: 0.1)
                isTextFieldFocused = true
                if AppConfiguration.shared.alternateMarkdown {
                    scrollToBottom(proxy: proxy, animated: true, delay: 1)
                }
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
            .onChange(of: session.isAddingConversation) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: session.input) {
                if session.input.contains("\n") || (session.input.count > 105) || (session.input.isEmpty){
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.resetMarker) {
                if (session.resetMarker == session.conversations.count - 1) {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.errorDesc) {
                scrollToBottom(proxy: proxy)
            }
//            Spacer() // enable this to change toolbar color
        }
    }
    
    private func DeleteBtn(proxy: ScrollViewProxy) -> some View {
        Button("hidden") {
            if let lastConversation = session.conversations.last {
                session.removeConversation(lastConversation)
            }
        }
        .keyboardShortcut(.delete, modifiers: .command)
        .frame(width: 1, height: 1) 
    }
}
#endif
