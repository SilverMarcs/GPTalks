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

    @Query(sort: \Provider.date, order: .reverse) var providers: [Provider]
    @Query var sessions: [Session]

    @State private var prevCount = 0

    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        ScrollViewReader { proxy in
            List(selection: $sessionVM.selections) {
                ForEach(sessions.prefix(sessionVM.chatCount), id: \.self) { session in
                    SessionListItem(session: session)
                }
                .onDelete(perform: deleteItems)
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
            .toolbar {
                SessionListToolbar()
            }
            #if os(macOS)
            .frame(minWidth: 240)
            .onAppear {
                if let first = sessions.first {
                    DispatchQueue.main.async {
                        sessionVM.selections = [first]
                    }
                }
            }
            #endif
            #if !os(macOS)
            .listStyle(.inset)
            .searchable(text: $sessionVM.searchText)
            #endif
        }
    }
    
    init(
        sort: SortDescriptor<Session> = SortDescriptor(
            \Session.date, order: .reverse), searchString: String
    ) {
        _sessions = Query(
            filter: #Predicate {
                if searchString.isEmpty {
                    return !$0.isQuick
                } else {
                    return !$0.isQuick && $0.title.localizedStandardContains(searchString)
                }
            }, sort: [sort], animation: .default)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sessions[index])
            }
        }
        
        try? modelContext.save()
    }
}

#Preview {
    SessionList(
        sort: SortDescriptor(\Session.date, order: .reverse), searchString: ""
    )
    .frame(width: 400)
    .modelContainer(for: Session.self, inMemory: true)
    .environment(SessionVM())
}
