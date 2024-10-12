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
    
    @State var showingInspector: Bool = true
    
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
        .inspector(isPresented: $showingInspector) {
            if let chatSession = sessionVM.activeSession {
                ChatInspector(session: chatSession, showingInspector: $showingInspector)
            } else {
                Text("Open a chat session for inspector")
                    .font(.title)
            }
        }
    }
}

#Preview {
    ChatContentView()
        .modelContainer(for: ChatSession.self, inMemory: true)
        .environment(ChatSessionVM(modelContext: DatabaseService.shared.container.mainContext))
}
#endif
