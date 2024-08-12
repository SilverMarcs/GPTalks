//
//  FolderView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/12/24.
//

import SwiftUI
import SwiftData

struct FolderView: View {
    let folder: Folder
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        HStack {
            Image(systemName: "folder")
                .foregroundStyle(.accent)
            Text(folder.title)
            Spacer()
            Text("\(folder.sessions.count)")
        }
//        .dropDestination(for: String.self) { items, location in
//            handleDrop(items)
//        } isTargeted: { isTargeted in
//            // You can use this to provide visual feedback when dragging over
//        }
    }
    
    private func handleDrop(_ items: [String]) -> Bool {
        guard let item = items.first else { return false }

        let uuid = item
        moveSessionToFolder(uuid: UUID(uuidString: uuid)!)
        return true
    }
    
    private func moveSessionToFolder(uuid: UUID) {
        if let session = try? modelContext.fetch(FetchDescriptor<Session>(predicate: #Predicate<Session> { $0.id == uuid })).first {
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

//#Preview {
//    FolderView()
//}
