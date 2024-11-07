//
//  ImageSessionList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData

struct ImageSessionList: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ImageSessionVM.self) var imageVM
    @Environment(\.modelContext) var modelContext
    @ObservedObject var config = AppConfig.shared
    
    @Query(sort: \ImageSession.order, order: .forward, animation: .default)
    var sessions: [ImageSession]
    
    var body: some View {
        @Bindable var imageVM = imageVM
        
        ScrollViewReader { proxy in
            List(selection: $imageVM.selections) {
                ChatListCards(sessionCount: "↗", imageSessionsCount: String(sessions.count))
                
                ForEach(sessions) { session in
                    ImageListRow(session: session)
                        .tag(session)
                        .deleteDisabled(session.isStarred)
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(Color.gray.opacity(0.2))
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: move)
            }
            .toolbar {
                ImageSessionToolbar()
            }
            .navigationTitle("Images")
            .searchable(text: $imageVM.searchText, placement: searchPlacement)
            .task {
                if imageVM.selections.isEmpty, let first = sessions.first, !(horizontalSizeClass == .compact) {
                    imageVM.selections = [first]
                }
            }
        }
    }
    
    private var searchPlacement: SearchFieldPlacement {
        #if os(macOS)
        return .sidebar
        #else
        return .automatic
        #endif
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets.sorted().reversed() {
                modelContext.delete(sessions[index])
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
            session.order = index
        }
    }
}


#Preview {
    ImageSessionList()
}
