//
//  ChatRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct ChatRow: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.openWindow) var openWindow
    @Environment(ChatVM.self) private var chatVM
    
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat
    
    var swipeTip = SwipeActionTip()
    
    var body: some View {
        row
        .swipeActions(edge: .leading) {
            swipeActionsLeading
        }
        .swipeActions(edge: .trailing) {
            swipeActionsTrailing
        }
        #if os(macOS)
        .contextMenu {
            Button {
                openWindow(value: chat.id)
            } label: {
                Label("Open in New Window", systemImage: "rectangle.on.rectangle")
                    .labelStyle(.titleAndIcon)
            }
        }
        #endif
    }
    var row: some View {
        HStack {
            ProviderImage(provider: chat.config.provider, radius: 8, frame: imageSize, scale: .medium)
                .symbolEffect(.bounce, options: .speed(0.5), isActive: chat.isReplying)
            
            HighlightedText(text: chat.title, highlightedText: chatVM.searchText, selectable: false)
                .lineLimit(1)
                .font(font)
                .opacity(0.9)
            
            Spacer()
            
            chatStatusMarker
                .imageScale(.small)
            
            Text(chat.config.model.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fontWidth(.compressed)
        }
        .padding(padding)
    }
    
    var imageSize: CGFloat {
        #if os(macOS)
        return 23
        #else
        return 26
        #endif
    }
    
    var font: Font {
        #if os(macOS)
        return .headline.weight(.regular)
        #else
        return .headline.weight(.medium)
        #endif
    }
    
    var padding: CGFloat {
        #if os(macOS)
        return 3
        #else
        return 4
        #endif
    }
    
    @ViewBuilder
    var chatStatusMarker: some View {
        switch chat.status {
        case .starred:
            Image(systemName: "star.fill")
                .foregroundStyle(.orange)
        case .archived:
            Image(systemName: "archivebox.fill")
                .foregroundStyle(.gray)
        case .quick:
            Image(systemName: "bolt.fill")
                .foregroundStyle(.yellow)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    var swipeActionsLeading: some View {
        if chat.status != .starred {
            Button {
                SwipeActionTip().invalidate(reason: .actionPerformed)
                
                if chatVM.selections.contains(chat) {
                    chatVM.selections.remove(chat)
                }
                
                chat.status = (chat.status == .archived) ? .normal : .archived
            } label: {
                Label("Archive", systemImage: chat.status == .archived ? "tray.and.arrow.up.fill" : "archivebox")
            }
            .tint(chat.status == .archived ? .blue : .gray)
        }
        
        if chat.status != .archived {
            Button {
                SwipeActionTip().invalidate(reason: .actionPerformed)
                chat.status = chat.status == .starred ? .normal : .starred
            } label: {
                Label(chat.status == .starred ? "Unstar" : "Star", systemImage: chat.status == .starred ? "star.slash" : "star")
            }
            .tint(.orange)
        }
    }
    
    @ViewBuilder
    var swipeActionsTrailing: some View {
        if chat.status != .starred {
            Button(role: .destructive) {
                SwipeActionTip().invalidate(reason: .actionPerformed)

                if chatVM.selections.contains(chat) {
                    chatVM.selections.remove(chat)
                }
                
                modelContext.delete(chat)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}

#Preview {
    List {
        ChatRow(chat: .mockChat)
            .environment(ChatVM())
    }
    .frame(width: 400)
}
