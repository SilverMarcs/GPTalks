//
//  iOSMessages.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

#if os(iOS)
    import SwiftUI

    struct iOSMessages: View {
        @Environment(\.colorScheme) var colorScheme
        @EnvironmentObject var viewModel: DialogueViewModel

        @ObservedObject var session: DialogueSession

        @State private var previousCount: Int = 0
        @State private var didUserTap: Bool = false

        var body: some View {
            ScrollViewReader { proxy in
                ScrollView {
                    ConversationView(session: session)
                        .padding(.horizontal)

                    Spacer()
                        .id("bottomID")
                }
                .onTapGesture {
                    didUserTap = true
                    hideKeyboard()
                }
                .onAppear {
                    scrollToBottom(proxy: proxy, animated: false)
                }
                .onChange(of: session.input) {
                    scrollToBottom(proxy: proxy)
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
            .onTapGesture {
                hideKeyboard()
            }
            .toolbar {
                ToolbarItems(session: session)
            }
        }
    }

    import UIKit
    extension View {
        func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
#endif
