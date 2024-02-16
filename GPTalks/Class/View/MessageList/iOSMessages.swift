//
//  iOSMessages.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

#if !os(macOS)
import SwiftUI
import VisualEffectView

struct iOSMessages: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(DialogueViewModel.self) private var viewModel

    var session: DialogueSession

    @State private var shouldStopScroll: Bool = false
    @State private var showScrollButton: Bool = false

    @FocusState var isTextFieldFocused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    Spacer()
                        .frame(height: 10)

                    ForEach(session.conversations) { conversation in
                        ConversationView(session: session, conversation: conversation)
                    }
                    .padding(.horizontal, 12)

                    ErrorDescView(session: session)

                    ScrollSpacer

                    GeometryReader { geometry in
                        Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                    }
                }

                scrollBtn(proxy: proxy)
            }
            #if !os(visionOS)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let bottomReached = value > UIScreen.main.bounds.height
                shouldStopScroll = bottomReached
                showScrollButton = bottomReached
            }
            .scrollDismissesKeyboard(.interactively)
            #endif
            .listStyle(.plain)
            .onAppear {
//                    scrollToBottom(proxy: proxy, animated: false)
                scrollToBottom(proxy: proxy, animated: true, delay: 0.2)
                scrollToBottom(proxy: proxy, animated: true, delay: 0.4)
                scrollToBottom(proxy: proxy, animated: true, delay: 0.8)
            }
            .onTapGesture {
                isTextFieldFocused = false
            }
            .onChange(of: isTextFieldFocused) {
                if !isTextFieldFocused {
                    scrollToBottom(proxy: proxy, delay: 0.2)
                }
            }
            .onChange(of: session.input) {
                if session.input.contains("\n") || (session.input.count > 25) || (session.input.isEmpty) {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.resetMarker) {
                if session.resetMarker == session.conversations.count - 1 {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.errorDesc) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: session.conversations.last?.content) {
                if !shouldStopScroll {
                    scrollToBottom(proxy: proxy, animated: true)
                }
            }
            .onChange(of: session.conversations.count) {
                shouldStopScroll = false
            }
            .onChange(of: session.isAddingConversation) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: session.inputImage) {
                if session.inputImage != nil {
                    if !session.configuration.provider.visionModels.contains(session.configuration.model) {
                        session.configuration.model = session.configuration.provider.visionModels[0]
                    }
                    scrollToBottom(proxy: proxy, animated: true)
                }
            }
            .onChange(of: session.configuration.provider) {
                if session.containsConversationWithImage {
                    session.configuration.model = session.configuration.provider.visionModels[0]
                } else {
                    session.configuration.model = session.configuration.provider.preferredModel
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomInputView(
                session: session,
                focused: _isTextFieldFocused
            )
            .onTapGesture {
                isTextFieldFocused = true
            }
        #if os(iOS)
            .background(
                VisualEffect(colorTint: colorScheme == .dark ? .black : .white, colorTintAlpha: 0.8, blurRadius: 18, scale: 1)
                    .ignoresSafeArea()
            )
            #else
            .background(.regularMaterial)
            #endif
        }
        #if os(visionOS)
        .navigationTitle(session.title)
        #endif
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItems(session: session)
        }
    }

    private var ScrollSpacer: some View {
        Spacer()
            .id("bottomID")
            .onAppear {
                showScrollButton = false
            }
            .onDisappear {
                showScrollButton = true
            }
    }

    private func scrollBtn(proxy: ScrollViewProxy) -> some View {
        Button {
            scrollToBottom(proxy: proxy)
        } label: {
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(.ultraThickMaterial)
                .background(Color.primary.opacity(0.8))
                .shadow(radius: 3)
                .clipShape(Circle())
                .padding(.bottom, 15)
                .padding(.trailing, 15)
        }
        .opacity(showScrollButton ? 1 : 0)
//            .animation(.interactiveSpring, value: showScrollButton)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#endif
