//
//  SessionListItem.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct SessionListItem: View {
    @Environment(\.modelContext) var modelContext
    @Environment(SessionVM.self) private var sessionVM
    
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var session: Session
    
    @State var isEditing = false
    @FocusState var isFocused: Bool
    
    var body: some View {
        Group {
            if config.compactList {
                compact
            } else {
                large
            }
        }
        .swipeActions(edge: .leading) {
            swipeActionsLeading
        }
    }
    
    var compact: some View {
        HStack {
            ProviderImage(provider: session.config.provider, radius: 8, frame: 23)
            
            titleField
                .font(.headline)
                .fontWeight(.regular)
                .lineLimit(1)
            
            Spacer()
            
            Text(session.config.model.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if session.isStarred {
                Image(systemName: "star.fill")
                    .foregroundStyle(.orange)
                    .imageScale(.small)
            }
        }
        .padding(3)
    }
    
    var large: some View {
        HStack {
            ProviderImage(provider: session.config.provider, radius: 9, frame: 29)
            
            VStack {
                HStack {
                    titleField
                        .lineLimit(1)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(session.config.model.name)
                        .font(.caption)
                }
                
                HStack {
                    Text(subText)
                    #if os(macOS)
                        .font(.callout)
                    #else
                        .font(.footnote)
                    #endif
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if session.isStarred {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.orange)
                            .imageScale(.small)
                    }
                }
            }
        }
        #if os (macOS)
        .padding(5)
        #else
        .padding(3)
        #endif
    }
    
    var subText: String {
        if session.isReplying {
            return "Generating…"
        }
        let lastMessage = session.groups.last?.activeConversation.content ?? ""
        return lastMessage.isEmpty ? "Start a conversation" : lastMessage
    }

    
    var titleField: some View {
        Group {
            if isEditing {
                TextField("Title", text: $session.title, onCommit: {
                    isEditing.toggle()
                })
                .padding(.vertical, -2)
                .focused($isFocused)
            } else {
                Text(session.title)
                    .lineLimit(1)
            }
        }
    }
    
    var swipeActionsTrailing: some View {
        Button(role: .destructive) {
            modelContext.delete(session)
        } label: {
            Label("Delete", systemImage: "trash")
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
            
            Button {
                isEditing.toggle()
                isFocused = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.accentColor)
        }
    }
}

#Preview {
    List {
        SessionListItem(session: Session())
            .environment(SessionVM())
    }
    .frame(width: 250)
}
