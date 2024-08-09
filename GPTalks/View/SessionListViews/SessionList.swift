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
    
    // predicate to filter out quick sessions
    @Query(filter: #Predicate { !$0.isQuick }, sort: [SortDescriptor(\Session.order, order: .forward)], animation: .default)
    var sessions: [Session]
    
    var filteredSessions: [Session] {
        if sessionVM.searchText.isEmpty {
            return sessions
        } else {
            return sessions.filter { session in
                session.title.localizedStandardContains(sessionVM.searchText) ||
                (AppConfig.shared.expensiveSearch &&
                session.unorderedGroups.contains { group in
                    group.conversationsUnsorted.contains { conversation in
                        conversation.content.localizedStandardContains(sessionVM.searchText)
                    }
                })
            }
        }
    }
    
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        ScrollViewReader { proxy in
            List(selection: $sessionVM.selections) {
                SessionListCards()
                
                if !sessionVM.searchText.isEmpty && sessions.isEmpty {
                    ContentUnavailableView.search(text: sessionVM.searchText)
                } else {
                    ForEach(filteredSessions.prefix(sessionVM.chatCount), id: \.self) { session in
                        SessionListItem(session: session)
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
                if let first = sessions.first {
                    proxy.scrollTo(first, anchor: .top)
                }
            }
            .onAppear {
                if let first = sessions.first, sessionVM.selections.isEmpty, !isIOS() {
                    DispatchQueue.main.async {
                        sessionVM.selections = [first]
                    }
                }
            }
        }
    }
    
//    init(searchString: String) {
//        _sessions = Query(
//            filter: #Predicate {
//                if searchString.isEmpty {
//                    return !$0.isQuick
//                } else {
//                    return !$0.isQuick &&
//                        ($0.title.localizedStandardContains(searchString) ||
//                         $0.unorderedGroups.contains { group in
//                            group.conversationsUnsorted.contains { conversation in
//                                conversation.content.localizedStandardContains(searchString)
//                            }
//                        })
//                }
//            },
//            sort: [
//                SortDescriptor(\Session.order, order: .forward),
//            ],
//            animation: .default
//        )
//    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets.sorted().reversed() {
                if !sessions[index].isStarred {
                    // TODO: check if part of sessionVM.selections
                    modelContext.delete(sessions[index])
                }
            }
            
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
            withAnimation {
                session.order = index
            }
        }
        
        try? modelContext.save()
    }
}

#Preview {
    SessionList()
    .frame(width: 400)
    .modelContainer(for: Session.self, inMemory: true)
    .environment(SessionVM())
}
