//
//  ChatSessionList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/12/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ChatSessionList: View {
    @Environment(SessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    @ObservedObject var config = AppConfig.shared
    
    @Query(filter: #Predicate { !$0.isQuick }, sort: [SortDescriptor(\Session.order, order: .forward)], animation: .default)
    var sessions: [Session]
    
    @Query(sort: [SortDescriptor(\Folder.order, order: .forward)], animation: .default)
    var folders: [Folder]
    
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        ScrollViewReader { proxy in
            List(selection: $sessionVM.selections) {
                SessionListCards(sessionCount: String(sessions.count), imageSessionsCount: "?")
                    .dropDestination(for: String.self) { items, location in
                        handleDropToRoot(items)
                    }
                    .padding(.leading, -paddingOffset)
                
                if sessionVM.searchText.isEmpty == false && sessions.isEmpty && folders.isEmpty {
                    ContentUnavailableView.search(text: sessionVM.searchText)
                } else {
                    treeContent
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(Color.gray.opacity(0.2))
#if !os(macOS)
                        .listSectionSeparator(.hidden)
#endif
                }
            }
            .onChange(of: sessions.count) {
                proxy.scrollTo(String.topID, anchor: .top)
            }
            .task {
                if let first = sessions.first, sessionVM.selections.isEmpty, !isIOS() {
                    DispatchQueue.main.async {
                        sessionVM.selections = [first]
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            newFolderButton
        }
    }
    
    @ViewBuilder
    private var treeContent: some View {
        ForEach(folders, id: \.self) { folder in
            DisclosureGroup {
                if folder.sessions.isEmpty {
                    Text("Empty folder")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(folder.sessions.sorted(by: { $0.order < $1.order }), id: \.self) { session in
                        SessionListItem(session: session)
                            .draggable(session.id.uuidString)
                            .contextMenu {
                                Button("Ungroup") {
                                    session.folder = nil
                                }
                            }
                    }
                    .onDelete { offsets in
                        deleteItemsInFolder(folder: folder, offsets: offsets)
                    }
                    .onMove(perform: { source, destination in
                        moveSessionsWithinFolder(folder: folder, from: source, to: destination)
                    })
                }
            } label: {
                FolderLabel(folder: folder)
            }
            .dropDestination(for: String.self) { items, location in
                handleDropToFolder(items, folder: folder)
            } isTargeted: { isTargeted in
                // can use this to provide visual feedback when dragging over
            }
        }
        .onDelete(perform: deleteFolders)
        .onMove(perform: moveFolders)
        
        ForEach(filteredSessions.filter { $0.folder == nil }, id: \.self) { session in
            SessionListItem(session: session)
                .draggable(session.id.uuidString)
        }
        .onDelete(perform: deleteItemsInRoot)
        .onMove(perform: moveSessionsInRoot)
        .padding(.leading, -paddingOffset)
        
        Color.clear
            .dropDestination(for: String.self) { items, location in
                handleDropToRoot(items)
            }
    }
    
    var filteredSessions: [Session] {
        return sessions.filter { session in
            sessionVM.searchText.isEmpty ||
            session.title.localizedStandardContains(sessionVM.searchText) ||
            (AppConfig.shared.expensiveSearch &&
             session.unorderedGroups.contains { group in
                 group.activeConversation.content.localizedCaseInsensitiveContains(sessionVM.searchText)
             })
        }
    }
    
    func createFolder(title: String) {
        let newFolder = Folder(title: title, order: folders.count)
        modelContext.insert(newFolder)
    }
    
    var newFolderButton: some View {
        HStack {
            Button {
                createFolder(title: "New Folder")
            } label: {
                Label("New Folder", systemImage: "folder.badge.plus")
            }
            .buttonStyle(.plain)
            .font(.callout)
            .foregroundStyle(.secondary)
            
            Spacer()
        }
        .padding(10)
    }
    
    var paddingOffset: CGFloat {
        7.5
    }
}
