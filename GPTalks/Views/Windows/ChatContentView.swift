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
    @Environment(ChatVM.self) private var sessionVM
    
    var body: some View {
        NavigationSplitView {
            ChatList()
        } detail: {
            ChatDetail()
        }
    }
}

#Preview {
    ChatContentView()
        .modelContainer(for: Chat.self, inMemory: true)
        .environment(ChatVM(modelContext: DatabaseService.shared.container.mainContext))
}
#endif
