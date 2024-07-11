//
//  ConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
//import IsScrolling
import KeyboardShortcuts

struct ConversationList: View {
    var session: Session
    @Environment(\.modelContext) var modelContext
    @Environment(SessionVM.self) private var sessionVM
    
    @State private var hasUserScrolled = false
    @State private var isScrolling = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(session.groups, id: \.self) { group in
                        ConversationGroupView(group: group)
                    }

                    ErrorMessageView(session: session)
                    
                    Color.clear.id(String.bottomID).frame(height: 20)
                }
//                .scrollSensor()
                .padding()
                .padding(.top, -10)
            }
            .onAppear {
                session.proxy = proxy
            }
            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                if session.isReplying {
                    hasUserScrolled = true
                }
            }
            .task {
                KeyboardShortcuts.onKeyUp(for: .sendMessage) { [self] in
                    Task { await session.sendInput() }
                }
            }
//            .scrollStatusMonitor($isScrolling, monitorMode: .common)
            .applyObservers(proxy: proxy, session: session, hasUserScrolled: $hasUserScrolled, isScrolling: $isScrolling)
            .navigationTitle(session.title)
            .navigationSubtitle(navSubtitle)
            .scrollContentBackground(.visible)
            .safeAreaInset(edge: .bottom) {
                InputView(session: session)
            }
            .toolbar {
                ConversationListToolbar(session: session)
            }
        }
    }
    
    var navSubtitle: String {
        "Tokens: " 
        + session.tokenCounter.formatToK()
        + " • " + session.config.systemPrompt.trimmingCharacters(in: .newlines).truncated(to: 45)
    }
}

#Preview {
    let session = Session()
    
    ConversationList(session: session)
}
