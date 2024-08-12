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
    
    @State var isEditing = false
    @State var newName = ""
    
    var body: some View {
        HStack {
            Image(systemName: "folder")
                .foregroundStyle(.cyan)
            
            Text(folder.title)
            
            Spacer()
            Text("\(folder.sessions.count)")
                .foregroundStyle(.secondary)
        }
        .padding(2)
        .lineLimit(1)
        .font(.headline)
        .fontWeight(.semibold)
        .opacity(0.9)
        .contextMenu {
            Button {
                isEditing = true
                newName = folder.title
            } label: {
                Label("Rename", systemImage: "pencil")
            }
        }
        .alert("Rename Folder", isPresented: $isEditing) {
            TextField("Rename Folder", text: $newName)
            
            Button("Cancel", role: .cancel) {
                isEditing = false
            }
            
            Button("Save") {
                folder.title = newName
                isEditing = false
            }
        }
    }
}

//#Preview {
//    FolderView()
//}
