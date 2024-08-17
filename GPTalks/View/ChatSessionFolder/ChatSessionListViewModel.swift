//
//  ChatSessionListViewModel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/13/24.
//

import SwiftUI
import SwiftData

extension ChatSessionList {
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
        }
    }
    
    func handleDropToFolder(_ items: [String], folder: Folder) -> Bool {
        for item in items {
            if let uuid = UUID(uuidString: item) {
                moveSessionToFolder(uuid: uuid, folder: folder)
            }
        }
        return true
    }
    
    func handleDropToRoot(_ items: [String]) -> Bool{
        for item in items {
            if let uuid = UUID(uuidString: item) {
                moveSessionToRoot(uuid: uuid, insertAt: filteredSessions.filter { $0.folder == nil }.count)
            }
        }
        return true
    }
    
    func moveSessionToFolder(uuid: UUID, folder: Folder) {
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
