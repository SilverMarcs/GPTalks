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
            ChatDetail()
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
