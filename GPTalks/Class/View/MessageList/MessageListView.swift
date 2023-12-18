//
//  MessageListView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI

#if os(macOS)
    import AppKit
#endif

struct MessageListView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: DialogueViewModel

    @ObservedObject var session: DialogueSession

    @State var isShowSettingsView = false
    @State var isShowDeleteWarning = false
    @State private var previousCount: Int = 0

    private let topID = "topID"
    private let bottomID = "bottomID"

    @State private var previousContent: String?
    @State private var isUserScrolling = false

    @State private var contentChangeTimer: Timer? = nil

    var body: some View {
        ScrollViewReader { proxy in
            Group {
                #if os(macOS)
                    macOsList
                        .onChange(of: session.conversations.last?.content) {
                            if session.conversations.last?.content != previousContent && !isUserScrolling {
                                scrollToBottomWithoutAnimation(proxy: proxy)
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
                #else
                    iosList
                        .onAppear {
                            scrollToBottom(proxy: proxy, slow: true)
                        }
                #endif
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
                if session.resetMarker == session.conversations.count - 1 {
                    scrollToBottom(proxy: proxy)
                }
            }
        }
        .navigationTitle($session.title)
        .alert("Delete all messages?", isPresented: $isShowDeleteWarning) {
            Button("Cancel", role: .cancel, action: {})
            Button("Confirm", role: .none, action: {
                session.resetErrorDesc()
                session.removeAllConversations()
            })
        }
    }

    #if os(macOS)
        var macOsList: some View {
            List {
                conversationView
                    .id(topID)

                Color.clear
                    .listRowSeparator(.hidden)
                    .id(bottomID)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomInputView(
                    session: session
                )
                .background(.bar)
            }
            .background(.background)
            .navigationSubtitle(session.configuration.model.name)
            .toolbar {
                ToolbarItems(session: session, isShowSettingsView: $isShowSettingsView, isShowDeleteWarning: $isShowDeleteWarning)
            }
        }
    #endif

    #if os(iOS)
        var iosList: some View {
            ScrollView {
                conversationView
                    .padding()
                    .id(topID)

                Spacer()
                    .id(bottomID)
            }
            .onTapGesture {
                hideKeyboard()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomInputView(
                    session: session
                )
                .background(
                    (colorScheme == .dark ? Color.black : Color.white)
                        .opacity(colorScheme == .dark ? 0.9 : 0.6)
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowSettingsView) {
                DialogueSettingsView(configuration: $session.configuration, provider: session.configuration.provider)
            }
            .toolbar {
                ToolbarItems(session: session, isShowSettingsView: $isShowSettingsView, isShowDeleteWarning: $isShowDeleteWarning)
            }
        }
    #endif

    var conversationView: some View {
        VStack {
            ForEach(session.conversations) { conversation in
                if conversation.role == "user" {
                    UserMessageView(conversation: conversation, session: session)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                if conversation.role == "assistant" {
                    AssistantMessageView(conversation: conversation, session: session)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if session.conversations.firstIndex(of: conversation) == session.resetMarker {
                    ContextResetDivider(session: session)
                        .padding(.vertical)
                }
            }

            if session.errorDesc != "" {
                ErrorDescView(session: session)
                    .padding()
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy, anchor: UnitPoint = .bottom, slow: Bool = false) {
        if slow {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    proxy.scrollTo(bottomID, anchor: anchor)
                }
            }
        } else {
            DispatchQueue.main.async {
                withAnimation {
                    proxy.scrollTo(bottomID, anchor: anchor)
                }
            }
        }
    }

    private func scrollToBottomWithoutAnimation(proxy: ScrollViewProxy, anchor: UnitPoint = .bottom) {
        DispatchQueue.main.async {
            proxy.scrollTo(bottomID, anchor: anchor)
        }
    }
}

#if canImport(UIKit)
    extension View {
        func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
#endif
