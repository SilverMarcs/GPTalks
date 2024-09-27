//
//  ChatContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData

struct ChatContentView: View {
    @Environment(ChatSessionVM.self) private var sessionVM
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
    var body: some View {
        NavigationSplitView {
            ChatSessionList(providers: providers)
        } detail: {
            if let chatSession = sessionVM.activeSession {
                ConversationList(session: chatSession, providers: providers)
            } else {
                Text("^[\(sessionVM.chatSelections.count) Chat Session](inflect: true) Selected")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.background)
                    .font(.title)
            }
        }
        .inspector(isPresented: .constant(true)) {
            if let chatSession = sessionVM.activeSession {
                ChatInspector(session: chatSession, providers: providers)
            } else {
                Image(systemName: "gear")
                    .imageScale(.large)
            }
        }
    }
}

#Preview {
    ChatContentView()
        .modelContainer(for: ChatSession.self, inMemory: true)
        .environment(ChatSessionVM())
}
