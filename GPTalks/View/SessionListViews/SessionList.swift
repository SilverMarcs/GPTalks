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
    
    @Query var sessions: [Session]
    
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        ScrollViewReader { proxy in
            List(selection: $sessionVM.selections) {
                SessionListCards()
                
                ForEach(sessions.prefix(sessionVM.chatCount), id: \.self) { session in
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
            .onChange(of: sessions.count) {
                if let first = sessions.first {
                    proxy.scrollTo(first, anchor: .top)
                }
            }
#if os(macOS)
            .onAppear {
                if let first = sessions.first, sessionVM.selections.isEmpty {
                    DispatchQueue.main.async {
                        sessionVM.selections = [first]
                    }
                }
            }
#endif
        }
    }
    
    init(searchString: String) {
        _sessions = Query(
            filter: #Predicate {
                if searchString.isEmpty {
                    return !$0.isQuick
                } else {
                    return !$0.isQuick && $0.title.localizedStandardContains(searchString)
                }
            },
            sort: [
                SortDescriptor(\Session.order, order: .forward),
            ],
            animation: .default
        )
    }

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
    SessionList(
        searchString: ""
    )
    .frame(width: 400)
    .modelContainer(for: Session.self, inMemory: true)
    .environment(SessionVM())
}
