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
    var isQuick: Bool = false
    
    @Environment(\.modelContext) var modelContext
    @Environment(SessionVM.self) private var sessionVM
    
    @State private var hasUserScrolled = false
    @State var showingInspector: Bool = false
    
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
                .padding(.top, -5)
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
            .navigationSubtitle( session.config.systemPrompt.trimmingCharacters(in: .newlines).truncated(to: 45))
            .navigationTitle(session.title)
            .toolbar {
                ConversationListToolbar(session: session)
            }
            #else
            .onTapGesture {
                showingInspector = false
            }
            .toolbar {
                showInspector
            }
            .inspector(isPresented: $showingInspector) {
                InspectorView(showingInspector: $showingInspector)
            }
            .toolbarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(session.config.model.name)
            #endif
            .applyObservers(proxy: proxy, session: session, hasUserScrolled: $hasUserScrolled)
            .scrollContentBackground(.visible)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isQuick {
                    ChatInputView(session: session)
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    #if !os(macOS)
    private var showInspector: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingInspector.toggle()
            } label: {
                Label("Show Inspector", systemImage: "info.circle")
            }
        }
    }
    #endif
    
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
