//
//  AssistantMessage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import MarkdownWebView

struct AssistantMessage: View {
    @ObservedObject var config = AppConfig.shared
    @Bindable var conversation: Conversation
    
    @State private var isHovering: Bool = false
    @State private var showingTextSelection = false
    
    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            Image(conversation.group?.session?.config.provider.type.imageName ?? "brain.SFSymbol")
                .resizable()
                .frame(width: 17, height: 17)
                .foregroundStyle(Color(hex: conversation.group?.session?.config.provider.color ?? "#00947A").gradient)
            
            VStack(alignment: .leading, spacing: 7) {
                if let model = conversation.model {
                    Text(conversation.dataFiles.isEmpty ? model.name : conversation.group?.session?.config.provider.imageModel.name ?? "")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.secondary)
                        #if os(macOS)
                        .padding(.top, 2)
                        #endif
                }
                
                MarkdownView(conversation: conversation)
                
                if !conversation.dataFiles.isEmpty {
                    DataFileView(dataFiles: $conversation.dataFiles, isCrossable: false, edge: .leading)
                }
                
                if conversation.isReplying {
                    ProgressView()
                        .controlSize(.small)
                }
                
                conversationMenuView
            }
        }
    #if !os(macOS)
    .contextMenu {
        if let group = conversation.group, !conversation.isReplying {
            ConversationMenu(group: group, isExpanded: .constant(true), toggleTextSelection: toggleTextSelection)
        }
    } preview: {
        Text("Assistant Message")
            .padding()
    }
    .sheet(isPresented: $showingTextSelection) {
        TextSelectionView(content: conversation.content)
    }
    #else
    .onHover { isHovered in
        self.isHovering = isHovered
    }
    #endif
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 30)
    }

    @ViewBuilder
    var conversationMenuView: some View {
        #if os(macOS)
        if let group = conversation.group, let session = group.session {
            ConversationMenu(group: group, isExpanded: .constant(true))
                .symbolEffect(.appear, isActive: !isHovering)
                .opacity(session.isReplying ? 0 : 1)
        }
        #endif
    }
    
    var spacing: CGFloat {
        #if os(macOS)
        10
        #else
        7
        #endif
    }
    
    func toggleTextSelection() {
        showingTextSelection.toggle()
    }
}

#Preview {
    return AssistantMessage(conversation: .mockAssistantConversation)
        .frame(width: 500, height: 300)
}

