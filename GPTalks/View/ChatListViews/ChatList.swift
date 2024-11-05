//
//  ChatList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftData
import SwiftUI

struct ChatList: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ChatVM.self) var chatVM
    @Environment(\.modelContext) var modelContext
    
    @Query(filter: #Predicate { !$0.isQuick },
           sort: [SortDescriptor(\Chat.date, order: .reverse)],
           animation: .default)
    var sessions: [Chat]
    
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        @Bindable var chatVM = chatVM

        List(selection: $chatVM.chatSelections) {
            ChatListCards(sessionCount: String(sessions.count), imageSessionsCount: "↗")
                .id(String.topID)
            
            ForEach(sessions) { session in
                ChatRow(session: session)
                    .tag(session)
                    .deleteDisabled(session.isQuick || session.isStarred)
                    #if os(macOS)
                    .listRowSeparator(.visible)
                    .listRowSeparatorTint(Color.gray.opacity(0.2))
                    #endif
            }
            .onDelete(perform: deleteItems)
        }
        .onChange(of: chatVM.searchText) {
            chatVM.debouncedSearch(sessions: sessions)
        }
        .navigationTitle("Chats")
        .toolbar {
            ChatListToolbar()
            
            ToolbarItem(placement: .keyboard) {
                Button("Search") {
                    isSearchFieldFocused.toggle()
                }
                .keyboardShortcut("f")
            }
        }
        .task {
            if let first = sessions.first, chatVM.chatSelections.isEmpty, horizontalSizeClass != .compact {
                chatVM.chatSelections = [first]
            }
        }
        .searchable(text: $chatVM.searchText, placement: searchPlacement)
        .searchFocused($isSearchFieldFocused, equals: true)
    }
    
    private var searchPlacement: SearchFieldPlacement {
        #if os(macOS)
        return .sidebar
        #else
        return .automatic
        #endif
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }
}

#Preview {
    ChatList()
    .frame(width: 400)
    .environment(ChatVM(modelContext: DatabaseService.shared.container.mainContext))
}
