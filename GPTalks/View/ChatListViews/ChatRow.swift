//
//  ChatRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct ChatRow: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.sidebarRowSize) private var sidebarRowSize
    @Environment(ChatVM.self) private var sessionVM
    
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var session: Chat
    
    var body: some View {
        Group {
            #if os(macOS)
            small
            #else
            large
            #endif
        }
        .swipeActions(edge: .leading) {
            swipeActionsLeading
        }
        .swipeActions(edge: .trailing) {
            swipeActionsTrailing
        }
    }
    
    var large: some View {
        HStack {
            ProviderImage(provider: session.config.provider, radius: 9, frame: 29, scale: .large)
                .symbolEffect(.pulse, isActive: session.isReplying)
            
            VStack(alignment: .leading) {
                HStack {
                    HighlightedText(text: session.title, highlightedText: sessionVM.searchText, selectable: false)
                        .lineLimit(1)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .opacity(0.9)
                    
                    Spacer()
                    
                    Text(session.config.model.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWidth(.compressed)
                }
                
                HStack {
                    Text(subText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    star
                }
            }
        }
        .padding(3)
    }
    
    var small: some View {
        HStack {
            ProviderImage(provider: session.config.provider, radius: 8, frame: 23, scale: .medium)
                .symbolEffect(.bounce, options: .speed(0.5), isActive: session.isReplying)
            
//            Text(session.title)
            HighlightedText(text: session.title, highlightedText: sessionVM.searchText, selectable: false)
                .lineLimit(1)
                .font(.headline)
                .fontWeight(.regular)
                .opacity(0.9)
            
            Spacer()
            
            Text(session.config.model.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fontWidth(.compressed)
            
            star
        }
        .padding(3)
        .symbolEffect(.bounce, options: .speed(0.5), isActive: session.isReplying)
    }
    
    @ViewBuilder
    var star: some View {
        if session.isStarred {
            Image(systemName: "star.fill")
                .foregroundStyle(.orange)
                .imageScale(.small)
                .symbolEffect(.appear, isActive: !session.isStarred)
        }
    }
    
    var subText: String {
        if session.isReplying {
            return "Generating…"
        }
        let lastMessage = session.groups.last?.activeThread.content ?? ""
        return lastMessage.isEmpty ? "Start a conversation" : lastMessage
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
        if session.isStarred || session.isQuick {
            return
        }
        
        if sessionVM.chatSelections.contains(session) {
            sessionVM.chatSelections.remove(session)
        }
        
        modelContext.delete(session)
        try? modelContext.save()
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

#Preview {
    List {
        ChatRow(session: .mockChat)
            .environment(ChatVM(modelContext: DatabaseService.shared.container.mainContext))
    }
    .frame(width: 250)
}
