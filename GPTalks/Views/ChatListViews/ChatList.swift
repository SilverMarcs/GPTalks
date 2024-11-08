//
//  ChatList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftData
import SwiftUI

struct ChatList: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ChatVM.self) var chatVM
    @Environment(\.modelContext) var modelContext
    @Environment(\.providers) private var providers
    
    @Query(filter: #Predicate { !$0.isQuick },
           sort: [SortDescriptor(\Chat.date, order: .reverse)]) // TODO: animation
    var chats: [Chat]
    
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        @Bindable var chatVM = chatVM

        List(selection: $chatVM.chatSelections) {
            ChatListCards(sessionCount: String(chats.count), imageSessionsCount: "↗")
                .id(String.topID)
            
            ForEach(chats) { session in
                ChatRow(session: session)
                    .tag(session)
                    .deleteDisabled(session.isQuick || session.isStarred)
                    #if os(macOS)
                    .listRowSeparator(.visible)
                    .listRowSeparatorTint(Color.gray.opacity(0.2))
                    #endif
            }
            .onDelete(perform: deleteItems)
        }
        .onChange(of: chatVM.searchText) {
            chatVM.debouncedSearch(chats: chats)
        }
        .navigationTitle("Chats")
        .toolbar {
            toolbar
        }
        .task {
            if let first = chats.first, chatVM.chatSelections.isEmpty, horizontalSizeClass != .compact {
                chatVM.chatSelections = [first]
            }
        }
        .searchable(text: $chatVM.searchText, placement: searchPlacement)
        .searchFocused($isSearchFieldFocused, equals: true)
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
            if chatVM.chatSelections.contains(chats[index]) {
                chatVM.chatSelections.remove(chats[index])
            }
            modelContext.delete(chats[index])
        }
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem { Spacer() }
        
        ToolbarItem {
            Menu {
                ForEach(providers) { provider in
                    Menu {
                        ForEach(provider.chatModels) { model in
                            Button(model.name) {
                                chatVM.createNewSession(provider: provider, model: model)
                            }
                        }
                    } label: {
                        Label(provider.name, systemImage: "cpu")
                    }
                }
            } label: {
                Label("Add Item", systemImage: "square.and.pencil")
            } primaryAction: {
                chatVM.createNewSession()
            }
            .menuIndicator(.hidden)
            .popoverTip(NewSessionTip())
        }
        
        ToolbarItem(placement: .keyboard) {
            Button("Search") {
                isSearchFieldFocused.toggle()
            }
            .keyboardShortcut("f")
        }
    }
}

#Preview {
    ChatList()
    .frame(width: 400)
    .environment(ChatVM(modelContext: DatabaseService.shared.container.mainContext))
}
