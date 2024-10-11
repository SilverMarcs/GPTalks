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
        
        #if os(macOS)
        CustomSearchField("Search", text: $imageVM.searchText)
            .padding(.horizontal, 10)
        #endif
        
        ScrollViewReader { proxy in
            List(selection: $imageVM.imageSelections) {
                SessionListCards(sessionCount: "↗", imageSessionsCount: String(sessions.count))
                
                if !imageVM.searchText.isEmpty && sessions.isEmpty {
                    ContentUnavailableView.search(text: imageVM.searchText)
                } else {
                    ForEach(filteredSessions) { session in
                        ImageListRow(session: session)
                            .tag(session)
                            .deleteDisabled(session.isStarred)
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(Color.gray.opacity(0.2))
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: move)
                }
            }
            .toolbar {
                ImageSessionToolbar()
            }
            .navigationTitle("Images")
            #if !os(macOS)
            .searchable(text: $imageVM.searchText)
            #endif
            .task {
                if imageVM.imageSelections.isEmpty, let first = sessions.first, !(horizontalSizeClass == .compact) {
                    imageVM.imageSelections = [first]
                }
            }
        }
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
    
    var filteredSessions: [ImageSession] {
        // Return early if search text is empty
        guard !imageVM.searchText.isEmpty else {
            if config.truncateList {
                return Array(sessions.prefix(config.listCount))
            } else {
                return sessions
            }
        }
        
        // Perform filtering if search text is not empty
        return sessions.filter { session in
            session.title.localizedStandardContains(imageVM.searchText) ||
            (AppConfig.shared.expensiveSearch &&
             session.imageGenerations.contains { generation in
                generation.config.prompt.localizedStandardContains(imageVM.searchText)
             })
        }
    }
}


#Preview {
    ImageSessionList()
}
