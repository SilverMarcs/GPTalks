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
    
    @Query var sessions: [ImageSession]
    
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        ScrollViewReader { proxy in
            List(selection: $sessionVM.imageSelections) {
                SessionListCards()
                
                ForEach(sessions.prefix(sessionVM.chatCount), id: \.self) { session in
//                    SessionListItem(session: session)
                    Text(session.title)
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(Color.gray.opacity(0.2))
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: move)
            }
            .onChange(of: sessions.count) {
                if let first = sessions.first {
                    sessionVM.imageSelections = [first]
                    proxy.scrollTo(first, anchor: .top)
                }
            }
#if os(macOS)
            .onAppear {
                if sessionVM.imageSelections.isEmpty, let first = sessions.first {
                    DispatchQueue.main.async {
                        sessionVM.imageSelections = [first]
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
                    return true
                } else {
                    return $0.title.localizedStandardContains(searchString)
                }
            },
            sort: [
                SortDescriptor(\ImageSession.order, order: .forward),
            ],
            animation: .default
        )
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
            
            // Save changes
            try? modelContext.save()
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        var updatedSessions = sessions
        updatedSessions.move(fromOffsets: source, toOffset: destination)
        
        for (index, session) in updatedSessions.enumerated() {
            session.order = index
        }
        
        try? modelContext.save()
    }
}


//#Preview {
//    ImageSessionList()
//}
