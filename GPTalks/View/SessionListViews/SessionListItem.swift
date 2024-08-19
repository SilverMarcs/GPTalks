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
    
    var body: some View {
        Group {
            if config.compactList {
                CommonCompactRow(provider: session.config.provider,
                                 model: session.config.model,
                                 title: session.title,
                                 isStarred: session.isStarred)
                .symbolEffect(.bounce, options: .speed(0.5), isActive: session.isReplying)
            } else {
                large
            }
        }
        .swipeActions(edge: .leading) {
            swipeActionsLeading
        }
    }
    
    var large: some View {
        HStack {
            ProviderImage(provider: session.config.provider, radius: 9, frame: 29, scale: .large)
                .symbolEffect(.pulse, isActive: session.isReplying)
            
            VStack(alignment: .leading) {
                HStack {
                    HighlightedText(text: session.title, highlightedText: sessionVM.searchText, shapeStyle: .yellow.opacity(0.5), selectable: false)
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
    let config = SessionConfig()
    let session = Session(config: config)
    
    List {
        SessionListItem(session: session)
            .environment(SessionVM())
    }
    .frame(width: 250)
}
