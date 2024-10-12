//
//  ChatContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

#if os(macOS)
import SwiftUI
import SwiftData

struct ChatContentView: View {
    @Environment(ChatSessionVM.self) private var sessionVM
    
    var body: some View {
        NavigationSplitView {
            ChatSessionList()
        } detail: {
            if let chatSession = sessionVM.activeSession {
                ConversationList(session: chatSession)
            } else {
                Text("^[\(sessionVM.chatSelections.count) Chat Session](inflect: true) Selected")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.background)
                    .font(.title)
            }
        }
        .pasteHandler()
    }
}

#Preview {
    ChatContentView()
        .modelContainer(for: ChatSession.self, inMemory: true)
        .environment(ChatSessionVM(modelContext: DatabaseService.shared.container.mainContext))
}
#endif
