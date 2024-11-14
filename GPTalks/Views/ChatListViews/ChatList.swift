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
    @Environment(ChatVM.self) var chatVM
    @Environment(SettingsVM.self) var settingsVM
    @Environment(\.modelContext) var modelContext
    @Environment(\.providers) private var providers
    
    @Query var chats: [Chat] // see init method below
    
    @FocusState private var isSearchFieldFocused: FocusedField?
    
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
        .navigationTitle("Chats")
        .toolbar {
            toolbar
        }
        .task {
            if let first = chats.first, chatVM.selections.isEmpty, horizontalSizeClass != .compact {
                chatVM.selections = [first]
            }
        }
        .searchable(text: $chatVM.searchText, placement: searchPlacement)
        .searchFocused($isSearchFieldFocused, equals: .searchBox)
        #if os(macOS)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            TipView(QuickPanelTip()) { action in
                if action.id == "launch-quick-panel" {
                    chatVM.isQuickPanelPresented = true
                    QuickPanelTip().invalidate(reason: .actionPerformed)
                }
            }
            .padding()
        }
        #endif
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
        
//        try? modelContext.save()
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
                                Task {
                                    await chatVM.createNewSession(provider: provider, model: model)
                                }
                            }
                        }
                    } label: {
                        Label(provider.name, systemImage: "cpu")
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
        
        #if os(macOS)
        ToolbarItem(placement: .keyboard) {
            Button("Search") {
                isSearchFieldFocused = .searchBox
            }
            .keyboardShortcut("f")
        }
        #endif
    }
    
    init(status: ChatStatus) {
        let statusId = status.id
        let normalId = ChatStatus.normal.id
        let starredId = ChatStatus.starred.id
        
        let sortDescriptor = SortDescriptor(\Chat.date, order: .reverse)
        
        let predicate: Predicate<Chat>
        if status == .normal {
            predicate = #Predicate<Chat> {
                $0.statusId == normalId || $0.statusId == starredId
            }
        } else {
            predicate = #Predicate<Chat> {
                $0.statusId == statusId
            }
        }
        
        _chats = Query(filter: predicate, sort: [sortDescriptor], animation: .default)
    }
}

#Preview {
    ChatList(status: .normal)
    .frame(width: 400)
    .environment(ChatVM())
    .environment(SettingsVM())
}
