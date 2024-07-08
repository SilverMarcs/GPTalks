//
//  ConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import IsScrolling

struct ConversationList: View {
    var session: Session
    @Environment(\.modelContext) var modelContext
    
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
                    
                    Color.clear.id(String.bottomID).frame(height: 25)
                }
                .scrollSensor()
                .padding()
            }
            .scrollStatusMonitor($isScrolling, monitorMode: .common)
            .applyObservers(proxy: proxy, session: session, hasUserScrolled: $hasUserScrolled, isScrolling: $isScrolling)
            .navigationTitle(session.title)
            .navigationSubtitle(session.config.systemPrompt)
            .scrollContentBackground(.visible)
            .safeAreaInset(edge: .bottom) {
                InputView(session: session)
            }
            .toolbar {
                ConversationListToolbar(session: session)
            }
        }
    }
}

#Preview {
    let session = Session()
    
    ConversationList(session: session)
}
