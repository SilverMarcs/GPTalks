//
//  ImageSessionList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData

struct ImageSessionList: View {
    @Environment(SessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    @ObservedObject var config = AppConfig.shared
    
    @Query(sort: \ImageSession.order, order: .forward, animation: .default)
    var sessions: [ImageSession]
    
    var filteredSessions: [ImageSession] {
        let filteredSessions: [ImageSession]
        
        if sessionVM.searchText.isEmpty {
            filteredSessions = sessions
        } else {
            filteredSessions = sessions.filter { session in
                session.title.localizedStandardContains(sessionVM.searchText) ||
                (AppConfig.shared.expensiveSearch &&
                session.imageGenerations.contains { generation in
                    generation.prompt.localizedStandardContains(sessionVM.searchText)
                })
            }
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
            List(selection: $sessionVM.imageSelections) {
                SessionListCards(sessionCount: "?", imageSessionsCount: String(sessions.count))
                
                if !sessionVM.searchText.isEmpty && sessions.isEmpty {
                    ContentUnavailableView.search(text: sessionVM.searchText)
                } else {
                    ForEach(filteredSessions, id: \.self) { session in
                        ImageListRow(session: session)
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(Color.gray.opacity(0.2))
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
#if os(macOS) || targetEnvironment(macCatalyst)
            .task {
                if sessionVM.imageSelections.isEmpty, let first = sessions.first {
                    DispatchQueue.main.async {
                        sessionVM.imageSelections = [first]
                    }
                }
            }
#endif
        }
    }

    private func deleteItems(offsets: IndexSet) {
        // if current selection is in the index, then set to nil
        
        withAnimation {
            for index in offsets.sorted().reversed() {
                if !sessions[index].isStarred {
                    modelContext.delete(sessions[index])
                }
            }
            
            // Then, update the order of remaining items
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
    }
}


//#Preview {
//    ImageSessionList()
//}
