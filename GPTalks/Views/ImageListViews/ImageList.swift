//
//  ImageList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData

struct ImageList: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ImageVM.self) var imageVM
    @Environment(\.modelContext) var modelContext
    @Environment(\.providers) var providers
    
    @Query(sort: \ImageSession.date, order: .reverse, animation: .default)
    var sessions: [ImageSession]
    
    var body: some View {
        @Bindable var imageVM = imageVM
        
        ScrollViewReader { proxy in
            List(selection: $imageVM.selections) {
                ChatListCards(sessionCount: "↗", imageSessionsCount: String(sessions.count))
                
                ForEach(sessions) { session in
                    ImageRow(session: session)
                        .tag(session)
                        .deleteDisabled(session.isStarred)
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(Color.gray.opacity(0.2))
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                toolbar
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
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem { Spacer() }
        
        ToolbarItem(placement: .automatic) {
            Menu {
                ForEach(providers) { provider in
                    Button(provider.name) {
                        imageVM.createNewSession(provider: provider)
                    }
                    .keyboardShortcut(.none)
                }
            } label: {
                Label("Add Item", systemImage: "square.and.pencil")
            } primaryAction: {
                imageVM.createNewSession()
            }
            .menuIndicator(.hidden)
            .popoverTip(NewSessionTip())
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
        for index in offsets {
            if imageVM.selections.contains(sessions[index]) {
                imageVM.selections.remove(sessions[index])
            }
            modelContext.delete(sessions[index])
        }
    }
}


#Preview {
    ImageList()
}
