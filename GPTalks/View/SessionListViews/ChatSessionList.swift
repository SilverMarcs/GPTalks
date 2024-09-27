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
    
    @Query(filter: #Predicate { !$0.isQuick }, sort: [SortDescriptor(\ChatSession.order, order: .forward)], animation: .default)
    var sessions: [ChatSession]
    var providers: [Provider]
    
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        #if os(macOS)
        CustomSearchField("Search", text: $sessionVM.searchText)
            .padding(.horizontal, 10)
        #endif
        
        ScrollViewReader { proxy in
            List(selection: $sessionVM.chatSelections) {
                SessionListCards(sessionCount: String(sessions.count), imageSessionsCount: "↗")
//                    .id(String.topID)
                
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
                    .onMove(perform: move)
                }
            }
            .toolbar {
                ChatSessionToolbar(providers: providers)
            }
            .navigationTitle("Chats")
            #if !os(macOS)
            .searchable(text: $sessionVM.searchText)
            #endif
            #if DEBUG
            .task {
                if let first = sessions.first, sessionVM.chatSelections.isEmpty, !isIOS() {
                    DispatchQueue.main.async {
                        sessionVM.chatSelections = [first]
                    }
                }
            }
            #endif
        }
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets.sorted().reversed() {
            modelContext.delete(sessions[index])
            
            let remainingSessions = sessions.filter { !$0.isDeleted }
            for (newIndex, session) in remainingSessions.enumerated() {
                session.order = newIndex
            }
        }
        try? modelContext.save()
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        var updatedSessions = sessions
        updatedSessions.move(fromOffsets: source, toOffset: destination)
        
        for (index, session) in updatedSessions.enumerated() {
            session.order = index
        }
        try? modelContext.save()
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
    ChatSessionList(providers: [])
    .frame(width: 400)
    .modelContainer(for: ChatSession.self, inMemory: true)
    .environment(ChatSessionVM())
}
