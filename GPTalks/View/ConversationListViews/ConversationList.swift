//
//  ConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData

struct ConversationList: View {
    @Environment(\.isQuick) var isQuick
    
    @Bindable var session: Session
    var providers: [Provider]
    
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Environment(\.modelContext) var modelContext
    @Environment(SessionVM.self) private var sessionVM
    
    @State private var hasUserScrolled = false
    @State var showingInspector: Bool = false
    
    var body: some View {
        if isQuick {
            content
        } else {
            content
                .modifier(PlatformSpecificModifiers(session: session, showingInspector: $showingInspector, hasUserScrolled: $hasUserScrolled))
        }
    }
    
    var content: some View {
        ScrollViewReader { proxy in
            Group {
                switch config.conversationListStyle {
                case .list:
                    listView
                case .scrollview:
                    vStackView
                }
            }
            .toolbar { ConversationListToolbar(session: session, providers: providers) }
            .task {
                sessionVM.selections.first?.refreshTokens()
                session.proxy = proxy
            }
            .applyObservers(proxy: proxy, session: session, hasUserScrolled: $hasUserScrolled)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isQuick {
                    ChatInputView(session: session)
                }
            }
            #if os(macOS) || targetEnvironment(macCatalyst)
            .searchable(text: $session.searchText)
            #endif
        }
    }
    
    var vStackView: some View  {
        ScrollView {
            VStack(spacing: spacing) {
                ForEach(session.groups, id: \.self) { group in
                    ConversationGroupView(group: group, providers: providers)
                }

                ErrorMessageView(session: session)
                
                colorSpacer
            }
            .padding()
            .padding(.top, -5)
        }
        .onScrollPhaseChange { oldPhase, newPhase in
            if newPhase == .interacting {
                hasUserScrolled = true
            }
        }
        .scrollContentBackground(.visible)
    }
    
    var listView: some View {
        List {
            VStack(spacing: 3) {
                ForEach(session.groups) { group in
                    ConversationGroupView(group: group, providers: providers)
                }
                .transaction { $0.animation = nil }

                ErrorMessageView(session: session)
            }
            .listRowSeparator(.hidden)
            .transaction { $0.animation = nil }
            
            Color.clear
                .id(String.bottomID)
                .listRowSeparator(.hidden)
                .transaction { $0.animation = nil }
        }
    }
    
    var colorSpacer: some View {
        Color.clear
            .frame(height: spacerHeight)
            .id(String.bottomID)
    }
    
    var spacerHeight: CGFloat {
        #if os(macOS) || targetEnvironment(macCatalyst)
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
        #if os(macOS) || targetEnvironment(macCatalyst)
        0
        #else
        15
        #endif
    }
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)
    let providers: [Provider] = []
    
    ConversationList(session: session, providers: providers)
        .environment(SessionVM())
}
