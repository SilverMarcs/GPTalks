//
//  ConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI

struct ConversationList: View {
    @Bindable var session: Session
    var isQuick: Bool = false
    
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Environment(\.modelContext) var modelContext
    @Environment(SessionVM.self) private var sessionVM
    
    @State private var hasUserScrolled = false
    @State var showingInspector: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            Group {
                if config.listView {
                    listView
                } else {
                    vStackView
                }
            }
            .onAppear {
                if !config.listView {
                    session.proxy = proxy
                }
            }
            .onChange(of: sessionVM.selections) {
                if !isIOS() {
                    scrollToBottom(proxy: proxy, delay: 0.2)
                    scrollToBottom(proxy: proxy, delay: 0.4)
                    if session.groups.count >= 7 {
                        scrollToBottom(proxy: proxy, delay: 0.8)
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    sessionVM.selections.first?.refreshTokens()
                }
            }
            .modifier(PlatformSpecificModifiers(session: session, showingInspector: $showingInspector, hasUserScrolled: $hasUserScrolled))
            .modifier(InspectorModifier(showingInspector: $showingInspector))
            .applyObservers(proxy: proxy, session: session, hasUserScrolled: $hasUserScrolled)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isQuick {
                    ChatInputView(session: session)
                }
            }
        }
    }
    
    var vStackView: some View  {
        ScrollView {
            VStack(spacing: spacing) {
                ForEach(session.groups, id: \.self) { group in
                    ConversationGroupView(group: group)
                }

                ErrorMessageView(session: session)
                
                colorSpacer
            }
            .padding()
            .padding(.top, -5)
        }
        .scrollContentBackground(.visible)
    }
    
    var listView: some View {
        List {
            VStack(spacing: 3) {
                ForEach(session.groups, id: \.self) { group in
                    ConversationGroupView(group: group)
                }

                ErrorMessageView(session: session)
            }
            .listRowSeparator(.hidden)
            
            Color.clear
                .id(String.bottomID)
        }
    }
    
    var colorSpacer: some View {
        #if os(macOS)
        Color.clear
            .frame(height: spacerHeight)
            .id(String.bottomID)
        #else
        GeometryReader { geometry in
            Color.clear
                .frame(height: spacerHeight)
                .id(String.bottomID)
                .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
        }
        #endif
    }
    
    var spacerHeight: CGFloat {
        #if os(macOS)
        if config.markdownProvider == .webview {
            20
        } else {
            1
        }
        #else
        10
        #endif
    }
    
    var spacing: CGFloat {
        #if os(macOS)
        0
        #else
        15
        #endif
    }
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)
    
    ConversationList(session: session)
        .environment(SessionVM())
}
