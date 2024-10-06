//
//  ImageListRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI
import SwiftData

struct ImageListRow: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var session: ImageSession
    
    var body: some View {
        CommonCompactRow(provider: session.config.provider,
                         model: session.config.model.name,
                         title: session.title,
                         isStarred: session.isStarred)
        .swipeActions(edge: .leading) {
            swipeActionsLeading
        }
    }
    
    var swipeActionsLeading: some View {
        Group {
            Button {
                session.isStarred.toggle()
            } label: {
                Label("Star", systemImage: "star")
            }
            .tint(.orange)
        }
    }
}

#Preview {
    ImageListRow(session: .mockImageSession)
}
