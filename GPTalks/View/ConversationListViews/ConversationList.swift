//
//  ConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import KeyboardShortcuts

struct ConversationList: View {
    var session: Session
    @Environment(\.modelContext) var modelContext
    @Environment(SessionVM.self) private var sessionVM
    
    @State private var hasUserScrolled = false
    @State private var isScrolling = false
    @State private var isShowSysPrompt = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: spacing) {
                    ForEach(session.groups, id: \.self) { group in
                        ConversationGroupView(group: group)
                    }

                    ErrorMessageView(session: session)
                    
                    GeometryReader { geometry in
                        Color.clear
                            .id(String.bottomID)
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                    }
                }
                .padding()
                .padding(.top, -15)
            }
            .onAppear {
                session.proxy = proxy
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                #if os(macOS)
                let bottomReached = value > NSScreen.main!.frame.height
                #else
                let bottomReached = value > UIScreen.main.bounds.height
                #endif
                hasUserScrolled = bottomReached
            }
            #if os(macOS)
            .task {
                KeyboardShortcuts.onKeyUp(for: .sendMessage) { [self] in
                    Task { await session.sendInput() }
                }
            }
            .navigationSubtitle(navSubtitle)
            .navigationTitle(session.title)
            .toolbar {
                ConversationListToolbar(session: session)
            }
            #else
            .toolbarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(session.config.model.name)
            .toolbarTitleMenu {
                ConversationListToolbar(session: session)
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        isShowSysPrompt.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .popover(isPresented: $isShowSysPrompt) {
                        ConversationTrailingPopup(session: session)
                    }
                }
            }
            #endif
            .applyObservers(proxy: proxy, session: session, hasUserScrolled: $hasUserScrolled, isScrolling: $isScrolling)

            .scrollContentBackground(.visible)
            .safeAreaInset(edge: .bottom) {
                InputView(session: session)
            }
        }
    }
    
    var spacing: CGFloat {
        #if os(macOS)
        0
        #else
        15
        #endif
    }
    
    var navSubtitle: String {
        "Tokens: " 
        + session.tokenCounter.formatToK()
        + " • " + session.config.systemPrompt.trimmingCharacters(in: .newlines).truncated(to: 45)
    }
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)
    
    ConversationList(session: session)
}
