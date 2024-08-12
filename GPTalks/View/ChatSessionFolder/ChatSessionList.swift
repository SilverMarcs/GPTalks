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
    
    @State var isDragging = false
    
    var body: some View {
        @Bindable var sessionVM = sessionVM
        
        ScrollViewReader { proxy in
            VStack {
                List(selection: $sessionVM.selections) {
                    SessionListCards()
                        .padding(.leading, -paddingOffset)
                    
                    if sessionVM.searchText.isEmpty == false && sessions.isEmpty && folders.isEmpty {
                        ContentUnavailableView.search(text: sessionVM.searchText)
                    } else {
                        treeContent
                            .listRowSeparatorTint(Color.gray.opacity(0.2))
#if !os(macOS)
                            .listSectionSeparator(.hidden)
#endif
                    }
                }
                .onChange(of: sessions.count) {
                    if let first = sessions.first {
                        proxy.scrollTo(first, anchor: .top)
                    }
                }
                .onAppear {
                    if let first = sessions.first, sessionVM.selections.isEmpty, !isIOS() {
                        DispatchQueue.main.async {
                            sessionVM.selections = [first]
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            newFolder
        }
    }
    
    @ViewBuilder
    private var treeContent: some View {
        ForEach(folders.sorted(by: { $0.order < $1.order }), id: \.self) { folder in
            DisclosureGroup(
                content: {
                    if folder.sessions.isEmpty {
                        Text("Empty folder")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(folder.sessions.sorted(by: { $0.order < $1.order }), id: \.self) { session in
                            SessionListItem(session: session)
                                .draggable(session.id.uuidString)
//                                .onDrag {
//                                    NSItemProvider(object: session.id.uuidString as NSString)
//                                }
                                .listRowSeparator(.visible)
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
                },
                label: {
                    FolderView(folder: folder)
                }
            )
            
            .listRowSeparator(.visible)
            .dropDestination(for: String.self) { items, location in
                handleDrop(items, folder: folder)
            } isTargeted: { isTargeted in
                // You can use this to provide visual feedback when dragging over
            }
        }
        .onDelete(perform: deleteFolders)
        .onMove(perform: moveFolders)
        
        ForEach(filteredSessions.filter { $0.folder == nil }, id: \.self) { session in
            SessionListItem(session: session)
                .draggable(session.id.uuidString)
                .listRowSeparator(.visible)
        }
        .onDelete(perform: deleteItemsInRoot)
        .onMove(perform: moveSessionsInRoot)
//        .onInsert(of: [.text], perform: insertToRoot)
        .padding(.leading, -paddingOffset)
        
        Color.clear
            .dropDestination(for: String.self) { items, location in
                // Iterate over all items in the drop
                for item in items {
                    if let uuid = UUID(uuidString: item) {
                        // Move each session to the root
                        moveSessionToRoot(uuid: uuid, insertAt: filteredSessions.filter { $0.folder == nil }.count)
                    }
                }
                return true
            }
    }
    
    private var filteredSessions: [Session] {
        return sessions.filter { session in
            sessionVM.searchText.isEmpty ||
            session.title.localizedStandardContains(sessionVM.searchText) ||
            (AppConfig.shared.expensiveSearch &&
             session.unorderedGroups.contains { group in
                group.conversationsUnsorted.contains { conversation in
                    conversation.content.localizedCaseInsensitiveContains(sessionVM.searchText)
                }
             })
        }
    }
    
    func createFolder(title: String) {
        let newFolder = Folder(title: title, order: folders.count)
        modelContext.insert(newFolder)
    }
    
    var newFolder: some View {
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
        8
    }
}

extension ChatSessionList {
//    func insertToRoot(at offset: Int, itemProvider: [NSItemProvider]) {
//        for provider in itemProvider {
//            provider.loadObject(ofClass: NSString.self) { (item, error) in
//                guard let itemString = item as? String,
//                      let uuid = UUID(uuidString: itemString) else {
//                    print("Failed to parse UUID from string: \(String(describing: item))")
//                    return
//                }
//
//                DispatchQueue.main.async {
//                    self.moveSessionToRoot(uuid: uuid, insertAt: offset)
//                }
//            }
//        }
//    }
    
    func moveSessionToRoot(uuid: UUID, insertAt index: Int) {
        if let session = try? modelContext.fetch(FetchDescriptor<Session>(predicate: #Predicate<Session> { $0.id == uuid })).first {
            // Remove the session from its current folder
            session.folder?.sessions.removeAll(where: { $0.id == session.id })
            
            // Move the session to root
            session.folder = nil
            
            // Update orders
            let rootSessions = sessions.filter { $0.folder == nil }
            for (i, s) in rootSessions.enumerated() {
                if i >= index {
                    s.order += 1
                }
            }
            session.order = index
            
            try? modelContext.save()
        }
    }
    
    func moveFolders(from source: IndexSet, to destination: Int) {
        var updatedFolders = folders
        updatedFolders.move(fromOffsets: source, toOffset: destination)
        
        for (index, folder) in updatedFolders.enumerated() {
            folder.order = index
        }
    }
    
    func moveSessionsInRoot(from source: IndexSet, to destination: Int) {
        var updatedSessions = filteredSessions.filter { $0.folder == nil }
        updatedSessions.move(fromOffsets: source, toOffset: destination)
        
        for (index, session) in updatedSessions.enumerated() {
            session.order = index
        }
    }
    
    func moveSessionsWithinFolder(folder: Folder, from source: IndexSet, to destination: Int) {
        var updatedSessions = folder.sessions
        updatedSessions.move(fromOffsets: source, toOffset: destination)
        
        for (index, session) in updatedSessions.enumerated() {
            session.order = index
        }
    }
    
    func deleteFolders(at offsets: IndexSet) {
        withAnimation {
            // Sort folders by order before deleting
            let sortedFolders = folders.sorted(by: { $0.order < $1.order })
            
            for index in offsets.sorted().reversed() {
                let folder = sortedFolders[index]
                modelContext.delete(folder)
            }
            
            // Save changes
            try? modelContext.save()
        }
    }
    
    func deleteItemsInFolder(folder: Folder, offsets: IndexSet) {
        withAnimation {
            // Get the sessions within the specified folder
            let sessionsInFolder = folder.sessions.sorted(by: { $0.order < $1.order })

            // Delete the sessions at the specified offsets
            for index in offsets.sorted().reversed() {
                let session = sessionsInFolder[index]
                if !session.isStarred { // Assuming you don't want to delete starred items
                    // Remove the session from the folder's list
                    folder.sessions.removeAll(where: { $0.id == session.id })
                    
                    // Delete the session from the modelContext
                    modelContext.delete(session)
                }
            }

            // Update the order of the remaining sessions in the folder
            for (newIndex, session) in folder.sessions.enumerated() {
                session.order = newIndex
            }

            try? modelContext.save()
        }
    }
    
    func deleteItemsInRoot(offsets: IndexSet) {
        withAnimation {
            // Get the sessions in the root (i.e., not in any folder)
            let rootSessions = filteredSessions.filter { $0.folder == nil }

            // Delete the sessions at the specified offsets
            for index in offsets.sorted().reversed() {
                let session = rootSessions[index]
                if !session.isStarred { // Assuming you don't want to delete starred items
                    modelContext.delete(session)
                }
            }

            // Update the order of the remaining sessions in the root
            let remainingRootSessions = filteredSessions.filter { $0.folder == nil && !$0.isDeleted }
            for (newIndex, session) in remainingRootSessions.enumerated() {
                session.order = newIndex
            }

            try? modelContext.save()
        }
    }
    
    private func handleDrop(_ items: [String], folder: Folder) -> Bool {
        for item in items {
            if let uuid = UUID(uuidString: item) {
                moveSessionToFolder(uuid: uuid, folder: folder)
            }
        }
        return true
    }
    
    private func moveSessionToFolder(uuid: UUID, folder: Folder) {
        if let session = try? modelContext.fetch(FetchDescriptor<Session>(predicate: #Predicate<Session> { $0.id == uuid })).first {
            // if alread in this folder, return
            if session.folder == folder {
                return
            }
            
            // Remove the session from its current folder (if any)
            session.folder?.sessions.removeAll(where: { $0.id == session.id })
            
            // Add the session to the new folder
            session.folder = folder
            folder.sessions.append(session)
            session.order = folder.sessions.count - 1
            
            // Save changes
            try? modelContext.save()
        }
    }
}
