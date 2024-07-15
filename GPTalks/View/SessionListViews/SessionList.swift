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
    
    @Query(sort: \Provider.date, order: .reverse) var providers: [Provider]
    @Query var sessions: [Session]
    
    @State private var prevCount = 0
    
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        ScrollViewReader { proxy in
            List(selection: $sessionVM.selections) {
                #if !os(macOS)
                cardView
                #endif
                
                ForEach(sessions.prefix(sessionVM.chatCount), id: \.self) { session in
                    SessionListItem(session: session)
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(Color.gray.opacity(0.2))
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: move)
            }
            .toolbar {
                SessionListToolbar()
            }
#if os(macOS)
            .frame(minWidth: 240)
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .padding(.top, -10)
            .onAppear {
                if let first = sessions.first {
                    DispatchQueue.main.async {
                        sessionVM.selections = [first]
                    }
                }
            }
            .onChange(of: sessions.count) {
                if sessions.count > prevCount {
                    if let first = sessions.first {
                        sessionVM.selections = [first]
                        withAnimation {
                            proxy.scrollTo(first, anchor: .top)
                        }
                    }
                }
            }
#else
            .navigationTitle("Sessions")
            .listStyle(.insetGrouped)
            .searchable(text: $sessionVM.searchText)
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
                SortDescriptor(\Session.date, order: .reverse)
            ],
            animation: .default
        )
    }
    
    #if !os(macOS)
    private var cardView: some View {
        Section {
            SessionListCards()
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listSectionSpacing(15)
    }
    #endif
    
    private func deleteItems(offsets: IndexSet) {
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

#Preview {
    SessionList(
        searchString: ""
    )
    .frame(width: 400)
    .modelContainer(for: Session.self, inMemory: true)
    .environment(SessionVM())
}
