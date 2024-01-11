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
        @EnvironmentObject var viewModel: DialogueViewModel

        @ObservedObject var session: DialogueSession

        @State private var previousCount: Int = 0
        @State private var didUserTap: Bool = false

        @FocusState var isTextFieldFocused: Bool

        var body: some View {
            ScrollViewReader { proxy in
                // TODO: see if can use List view here
                ScrollView {
                    Group {
                        ForEach(session.conversations) { conversation in
                            ConversationView(session: session, conversation: conversation)
                                .padding(.horizontal)
                        }
                        
                        if session.errorDesc != "" {
                            ErrorDescView(session: session)
                                .padding()
                        }
                        
                        Spacer()
                            .id("bottomID")
                    }
                    .padding(.vertical)
                }
                .onTapGesture {
                    didUserTap = true
                    isTextFieldFocused = false
                }
                .onAppear {
                    scrollToBottom(proxy: proxy, animated: false)
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
    }
#endif
