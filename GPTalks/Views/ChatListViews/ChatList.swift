//
//  ChatList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftData
import SwiftUI
import TipKit

struct ChatList: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.isSearching) private var isSearching
    @Environment(ChatVM.self) var chatVM
    @Environment(SettingsVM.self) var settingsVM
    @Environment(\.modelContext) var modelContext
    @Environment(\.providers) private var providers
    
    @Query var chats: [Chat] // see init method below
    
    var body: some View {
        @Bindable var chatVM = chatVM

        List(selection: $chatVM.selections) {
            ChatListCards(source: .chatlist, sessionCount: String(chats.count), imageSessionsCount: "↗")
            
                Group {
                    TipView(ChatCardTip())
                    TipView(SwipeActionTip())
                }
                .tipCornerRadius(8)
                .listRowInsets(EdgeInsets(top: -6, leading: -5, bottom: 10, trailing: -5))

            #if os(macOS)
            if isSearching {
                Text("Press Enter to search")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .bold()
                    .listRowSeparator(.hidden)
            }
            #endif
            
            if isSearching && chats.isEmpty {
                ContentUnavailableView.search
            } else {
                ForEach(chats) { session in
                    ChatRow(session: session)
                        .tag(session)
                        .deleteDisabled(session.status == .starred)
                        #if os(macOS)
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(Color.gray.opacity(0.2))
                        #endif
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle("Chats")
        .toolbar {
            toolbar
        }
        .task {
            if let first = chats.first, chatVM.selections.isEmpty, horizontalSizeClass != .compact {
                chatVM.selections = [first]
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
       for index in offsets {
           let chat = chats[index]
           
           // Skip starred chats
           if chat.status == .starred {
               continue
           }
           
           // Remove from selections if selected
           if chatVM.selections.contains(chat) {
               chatVM.selections.remove(chat)
           }
           
           // Archive if normal, delete if archived
           if chat.status == .normal {
               chat.status = .archived
           } else if chat.status == .archived {
               modelContext.delete(chat)
           }
       }
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem { Spacer() }
        
        ToolbarItem {
            Menu {
                ForEach(providers) { provider in
                    Button(provider.name) {
                        Task {
                            await chatVM.createNewSession(provider: provider)
                        }
                    }
                }
            } label: {
                Label("Add Item", systemImage: "square.and.pencil")
            } primaryAction: {
                Task {
                    await chatVM.createNewSession()
                }
            }
            .menuIndicator(.hidden)
            .popoverTip(NewChatTip())
        }
    }
    
    init(status: ChatStatus, searchText: String, searchTokens: [ChatSearchToken]) {
        let statusId = status.id
        let normalId = ChatStatus.normal.id
        let starredId = ChatStatus.starred.id
        
        let sortDescriptor = SortDescriptor(\Chat.date, order: .reverse)
        
        let statusPredicate: Predicate<Chat>
        if status == .normal {
            statusPredicate = #Predicate<Chat> {
                $0.statusId == normalId || $0.statusId == starredId
            }
        } else {
            statusPredicate = #Predicate<Chat> {
                $0.statusId == statusId
            }
        }
        
        let searchPredicate: Predicate<Chat>
        if searchText.count >= 2 {
            if searchTokens.isEmpty || (searchTokens.contains(.title) && searchTokens.contains(.messages)) {
                searchPredicate = #Predicate<Chat> {
                    $0.title.localizedStandardContains(searchText) ||
                    $0.unorderedThreads.contains {
                        $0.content.localizedStandardContains(searchText)
                    }
                }
            } else if searchTokens.contains(.title) {
                searchPredicate = #Predicate<Chat> {
                    $0.title.localizedStandardContains(searchText)
                }
            } else if searchTokens.contains(.messages) {
                searchPredicate = #Predicate<Chat> {
                    $0.unorderedThreads.contains {
                        $0.content.localizedStandardContains(searchText)
                    }
                }
            } else {
                searchPredicate = #Predicate<Chat> { _ in true }
            }
            
            // When searching, we ignore the status filter
            _chats = Query(filter: searchPredicate, sort: [sortDescriptor], animation: .default)
        } else {
            // When not searching, we apply the status filter
            let combinedPredicate = #Predicate<Chat> {
                statusPredicate.evaluate($0)
            }
            _chats = Query(filter: combinedPredicate, sort: [sortDescriptor], animation: .default)
        }
    }
}

#Preview {
    ChatList(status: .normal, searchText: "", searchTokens: [])
    .frame(width: 400)
    .environment(ChatVM())
    .environment(SettingsVM())
}
