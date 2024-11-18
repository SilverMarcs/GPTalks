//
//  ChatRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct ChatRow: View {
    @Environment(\.modelContext) var modelContext
    @Environment(ChatVM.self) private var sessionVM
    
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var session: Chat
    
    var swipeTip = SwipeActionTip()
    
    var body: some View {
        row
        .swipeActions(edge: .leading) {
            swipeActionsLeading
        }
        .swipeActions(edge: .trailing) {
            swipeActionsTrailing
        }
    }
    var row: some View {
        HStack {
            ProviderImage(provider: session.config.provider, radius: 8, frame: imageSize, scale: .medium)
                .symbolEffect(.bounce, options: .speed(0.5), isActive: session.isReplying)
            
            HighlightedText(text: session.title, highlightedText: sessionVM.searchText, selectable: false)
                .lineLimit(1)
                .font(font)
                .fontWeight(fontWeight)
                .opacity(0.9)
            
            Spacer()
            
            Text(session.config.model.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fontWidth(.compressed)
            
            chatStatusMarker
                .imageScale(.small)
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
        return .headline
        #else
        return .subheadline
        #endif
    }
    
    var fontWeight: Font.Weight {
        #if os(macOS)
        return .regular
        #else
        return .semibold
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
        switch session.status {
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
        if session.status != .starred {
            Button {
                SwipeActionTip().invalidate(reason: .actionPerformed)
                
                if sessionVM.selections.contains(session) {
                    sessionVM.selections.remove(session)
                }
                
                session.status = (session.status == .archived) ? .normal : .archived
            } label: {
                Label("Archive", systemImage: session.status == .archived ? "tray.and.arrow.up.fill" : "archivebox")
            }
            .tint(session.status == .archived ? .blue : .gray)
        }
        
        if session.status != .archived {
            Button {
                SwipeActionTip().invalidate(reason: .actionPerformed)
                session.status = session.status == .starred ? .normal : .starred
            } label: {
                Label(session.status == .starred ? "Unstar" : "Star", systemImage: session.status == .starred ? "star.slash" : "star")
            }
            .tint(.orange)
        }
    }
    
    @ViewBuilder
    var swipeActionsTrailing: some View {
        if session.status != .starred {
            Button(role: .destructive) {
                SwipeActionTip().invalidate(reason: .actionPerformed)

                if sessionVM.selections.contains(session) {
                    sessionVM.selections.remove(session)
                }
                
                modelContext.delete(session)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}

#Preview {
    List {
        ChatRow(session: .mockChat)
            .environment(ChatVM())
    }
    .frame(width: 400)
}
