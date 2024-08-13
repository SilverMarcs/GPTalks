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
            vStackView
            .onAppear {
                session.proxy = proxy
                session.refreshTokens()
            }
            .modifier(PlatformSpecificModifiers(session: session, showingInspector: $showingInspector, hasUserScrolled: $hasUserScrolled))
            .modifier(InspectorModifier(showingInspector: $showingInspector))
            .scrollContentBackground(.visible)
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
