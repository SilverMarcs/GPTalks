//
//  ImageRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI
import SwiftData

struct ImageRow: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var session: ImageSession
    @Environment(ImageVM.self) private var imageVM
    
    var body: some View {
        HStack {
            ProviderImage(provider: session.config.provider, radius: 8, frame: 23, scale: .medium)
            
            HighlightedText(text: imageVM.searchText, highlightedText: imageVM.searchText)
                .lineLimit(1)
                .font(.headline)
                .fontWeight(.regular)
                .opacity(0.9)
            
            Spacer()
            
            Text(session.config.model.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fontWidth(.compressed)
            
            if session.isStarred {
                Image(systemName: "star.fill")
                    .foregroundStyle(.orange)
                    .imageScale(.small)
                    .symbolEffect(.appear, isActive: !session.isStarred)
            }
        }
        .padding(3)
        .swipeActions(edge: .leading) {
            swipeActionsLeading
        }
        .swipeActions(edge: .trailing) {
            swipeActionsTrailing
        }
    }
    
    var swipeActionsLeading: some View {
        Button {
            session.isStarred.toggle()
        } label: {
            Label("Star", systemImage: "star")
        }
        .tint(.orange)
    }
    
    var swipeActionsTrailing: some View {
        Button(role: .destructive) {
            if imageVM.selections.contains(session) {
                imageVM.selections.remove(session)
            }
            
            modelContext.delete(session)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

#Preview {
    ImageRow(session: .mockImageSession)
}
