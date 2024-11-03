//
//  SessionList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftData
import SwiftUI

struct ChatSessionList: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ChatSessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    @ObservedObject var config = AppConfig.shared
    
    @Query(filter: #Predicate { !$0.isQuick }, sort: [SortDescriptor(\ChatSession.date, order: .reverse)], animation: .default)
    var sessions: [ChatSession]
    
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        #if os(macOS)
        CustomSearchField("Search", text: $sessionVM.searchText)
            .focused($isSearchFieldFocused)
            .padding(.horizontal, 10)
            .onChange(of: sessionVM.hasFocus) {
                isSearchFieldFocused = sessionVM.hasFocus
            }
            .onChange(of: isSearchFieldFocused) {
                sessionVM.hasFocus = isSearchFieldFocused
            }
        #endif
        
        ScrollViewReader { proxy in
            List(selection: $sessionVM.chatSelections) {
                SessionListCards(sessionCount: String(sessions.count), imageSessionsCount: "↗")
                    .id(String.topID)
                
                ForEach(sessions) { session in
                    SessionListRow(session: session)
                        .tag(session)
                        .deleteDisabled(session.isQuick || session.isStarred)
                    #if os(macOS)
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(Color.gray.opacity(0.2))
                    #endif
                }
                .onDelete(perform: deleteItems)
            }
            .onChange(of: sessionVM.searchText) { _, _ in
                sessionVM.debouncedSearch(sessions: sessions)
            }
            .navigationTitle("Chats")
            .toolbar {
                ChatSessionToolbar()
            }
            .task {
                if let first = sessions.first, sessionVM.chatSelections.isEmpty, !(horizontalSizeClass == .compact) {
                    DispatchQueue.main.async {
                        sessionVM.chatSelections = [first]
                    }
                }
            }
            #if !os(macOS)
            .searchable(text: $sessionVM.searchText)
            #endif
        }
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }
}

#Preview {
    ChatSessionList()
    .frame(width: 400)
    .environment(ChatSessionVM(modelContext: DatabaseService.shared.container.mainContext))
}
