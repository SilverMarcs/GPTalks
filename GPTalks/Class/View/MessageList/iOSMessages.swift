//
//  iOSMessages.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

#if os(iOS)
    import SwiftUI
    import VisualEffectView

    struct iOSMessages: View {
        @Environment(\.colorScheme) var colorScheme
        @Environment(DialogueViewModel.self) private var viewModel

        var session: DialogueSession

        @State private var didUserTap: Bool = false
        @State private var showScrollButton: Bool = false

        @FocusState var isTextFieldFocused: Bool

        var body: some View {
            ScrollViewReader { proxy in
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        ForEach(session.conversations) { conversation in
                            ConversationView(session: session, conversation: conversation)
                        }
                        .padding(.horizontal, 10)

                        ErrorDescView(session: session)

                        Spacer()
                            .id("bottomID")
                            .onAppear {
                                showScrollButton = false
                            }
                            .onDisappear {
                                showScrollButton = true
                            }

                        GeometryReader { geometry in
                            Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                        }
                        .frame(height: 1)
                    }
                    scrollBtn(proxy: proxy)
                }
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    let bottomReached = value > UIScreen.main.bounds.height
                    didUserTap = bottomReached
                    showScrollButton = bottomReached
                }
                .scrollDismissesKeyboard(.immediately)
                .listStyle(.plain)
                .onAppear {
                    scrollToBottom(proxy: proxy, animated: false)
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
                .onChange(of: session.conversations.last?.content) {
                    if !didUserTap {
                        scrollToBottom(proxy: proxy, animated: false)
                    }
                }
                .onChange(of: session.conversations.count) {
                    didUserTap = false
                }
                .onChange(of: session.isAddingConversation) {
                    scrollToBottom(proxy: proxy)
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
                .background(
                    VisualEffect(colorTint: colorScheme == .dark ? .black : .white, colorTintAlpha: 0.8, blurRadius: 18, scale: 1)
                        .ignoresSafeArea()
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItems(session: session)
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
#endif

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
