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
    
    var swipeTip = SwipeActionTip()
    
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
        if session.status == .starred {
            Image(systemName: "star.fill")
                .foregroundStyle(.orange)
                .imageScale(.small)
                .symbolEffect(.appear, isActive: session.status != .starred)
        }
    }
    
    var subText: String {
        if session.isReplying {
            return "Generating…"
        }
        let lastMessage = session.threads.last?.content ?? ""
        return lastMessage.isEmpty ? "Start a conversation" : lastMessage
    }

    var swipeActionsLeading: some View {
        Button {
            SwipeActionTip().invalidate(reason: .actionPerformed)
            session.status = session.status == .starred ? .normal : .starred
            
        } label: {
            Label("Star", systemImage: "star")
        }
        .tint(.orange)
    }
    
    var swipeActionsTrailing: some View {
        Button(role: .destructive) {
            // TODO: do properly
            if session.status == .starred {
                return
            }
            
            SwipeActionTip().invalidate(reason: .actionPerformed)
            
            if sessionVM.chatSelections.contains(session) {
                sessionVM.chatSelections.remove(session)
            }
            
            modelContext.delete(session)
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
