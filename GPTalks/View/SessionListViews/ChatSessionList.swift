//
//  SessionList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftData
import SwiftUI

struct ChatSessionList: View {
    @Environment(ChatSessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    @ObservedObject var config = AppConfig.shared
    
    @Query(filter: #Predicate { !$0.isQuick }, sort: [SortDescriptor(\ChatSession.date, order: .reverse)], animation: .default)
    var sessions: [ChatSession]
    
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        #if os(macOS)
        CustomSearchField("Search", text: $sessionVM.searchText)
            .padding(.horizontal, 10)
        #endif
        
        ScrollViewReader { proxy in
            List(selection: $sessionVM.chatSelections) {
                SessionListCards(sessionCount: String(sessions.count), imageSessionsCount: "↗")
                    .id(String.topID)
                
                if !sessionVM.searchText.isEmpty && sessions.isEmpty {
                    ContentUnavailableView.search(text: sessionVM.searchText)
                } else {
                    ForEach(filteredSessions) { session in
                        SessionListRow(session: session)
                            .deleteDisabled(session.isQuick || session.isStarred)
                            .tag(session)
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(Color.gray.opacity(0.2))
                            #if !os(macOS)
                            .listSectionSeparator(.hidden)
                            #endif
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .toolbar {
                ChatSessionToolbar()
            }
            .navigationTitle("Chats")
            #if !os(macOS)
            .searchable(text: $sessionVM.searchText)
            #endif
            .task {
                if let first = sessions.first, sessionVM.chatSelections.isEmpty, !isIOS() {
                    DispatchQueue.main.async {
                        sessionVM.chatSelections = [first]
                    }
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }
    
    
    var filteredSessions: [ChatSession] {
        // Return early if search text is empty
        guard !sessionVM.searchText.isEmpty else {
            if config.truncateList {
                return Array(sessions.prefix(config.listCount))
            } else {
                return sessions
            }
        }
        
        // Perform filtering if search text is not empty
        return sessions.filter { session in
            session.title.localizedStandardContains(sessionVM.searchText) ||
            (AppConfig.shared.expensiveSearch &&
             session.unorderedGroups.contains { group in
                 group.activeConversation.content.localizedCaseInsensitiveContains(sessionVM.searchText)
             })
        }
    }
}

#Preview {
    ChatSessionList()
    .frame(width: 400)
    .environment(ChatSessionVM(modelContext: DatabaseService.shared.container.mainContext))
}
