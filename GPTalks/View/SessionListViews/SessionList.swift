//
//  SessionList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftData
import SwiftUI

struct SessionList: View {
    @Environment(SessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    @ObservedObject var config = AppConfig.shared
    
    @Query(filter: #Predicate { !$0.isQuick }, sort: [SortDescriptor(\Session.order, order: .forward)], animation: .default)
    var sessions: [Session]
    
    var filteredSessions: [Session] {
        let filteredSessions: [Session] = sessions.filter { session in
            sessionVM.searchText.isEmpty ||
            session.title.localizedStandardContains(sessionVM.searchText) ||
            (AppConfig.shared.expensiveSearch &&
             session.unorderedGroups.contains { group in
                 group.activeConversation.content.localizedCaseInsensitiveContains(sessionVM.searchText)
             })
        }
        
        if config.truncateList {
            return Array(filteredSessions.prefix(config.listCount))
        } else {
            return filteredSessions
        }
    }
    
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        ScrollViewReader { proxy in
            List(selection: $sessionVM.selections) {
                SessionListCards(sessionCount: String(sessions.count), imageSessionsCount: "?")
                    .id(String.topID)
                
                if !sessionVM.searchText.isEmpty && sessions.isEmpty {
                    ContentUnavailableView.search(text: sessionVM.searchText)
                } else {
                    ForEach(filteredSessions) { session in
                        SessionListRow(session: session)
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
            .onChange(of: sessions.count) {
                proxy.scrollTo(String.topID, anchor: .top)
            }
            .task {
                if let first = sessions.first, sessionVM.selections.isEmpty, !isIOS() {
                    DispatchQueue.main.async {
                        sessionVM.selections = [first]
                    }
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets.sorted().reversed() {
            if !sessions[index].isStarred {
                modelContext.delete(sessions[index])
                let remainingSessions = sessions.filter { !$0.isDeleted }
                for (newIndex, session) in remainingSessions.enumerated() {
                    session.order = newIndex
                }
//                try? modelContext.save()
            }
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        var updatedSessions = sessions
        updatedSessions.move(fromOffsets: source, toOffset: destination)
        
        for (index, session) in updatedSessions.enumerated() {
            withAnimation {
                session.order = index
            }
        }
    }
}

#Preview {
    SessionList()
    .frame(width: 400)
    .modelContainer(for: Session.self, inMemory: true)
    .environment(SessionVM())
}
