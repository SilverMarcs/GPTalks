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
    
    @Query var chats: [Chat]
    
    init(status: ChatStatus) {
        let statusId = status.id
        let starredId = ChatStatus.starred.id
        
        let sortDescriptor = SortDescriptor(\Chat.date, order: .reverse)
        let predicate = #Predicate<Chat> { $0.statusId == statusId || $0.statusId == starredId }
        
        _chats = Query(filter: predicate, sort: [sortDescriptor], animation: .default)
    }
    
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        @Bindable var chatVM = chatVM

        List(selection: $chatVM.chatSelections) {
            ChatListCards(sessionCount: String(chats.count), imageSessionsCount: "↗")
                .id(String.topID)
            
            TipView(SwipeActionTip())
                .listRowSeparator(.hidden)
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
        #if os(macOS)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack {
                TipView(OpenSettingsTip()) { action in
                    if action.id == "launch-settings" {
                        openWindow(id: "settings")
                        OpenSettingsTip().invalidate(reason: .actionPerformed)
                    }
                }
                .frame(height: 60)
                
                TipView(QuickPanelTip()) { action in
                    if action.id == "launch-quick-panel" {
                        settingsVM.isQuickPanelPresented = true
                        QuickPanelTip().invalidate(reason: .actionPerformed)
                    }
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
            .popoverTip(NewChatTip())
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
    ChatList(status: .normal)
    .frame(width: 400)
    .environment(ChatVM(modelContext: DatabaseService.shared.container.mainContext))
    .environment(SettingsVM())
}
