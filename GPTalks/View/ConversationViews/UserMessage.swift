//
//  UserMessage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct UserMessage: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(ChatSessionVM.self) private var sessionVM
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var conversation: Conversation
    @State var isHovered: Bool = false
    @State var isExpanded: Bool = false
    @State var showingTextSelection = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 7) {
            if !conversation.dataFiles.isEmpty {
                DataFileView(dataFiles: $conversation.dataFiles, isCrossable: false)
            }
            
            HighlightedText(text: conversation.content, highlightedText: sessionVM.searchText.count > 3 ? sessionVM.searchText : nil)
                #if os(macOS)
                .lineSpacing(2)
                #endif
                .font(.system(size: config.fontSize))
                .lineLimit(!isExpanded ? lineLimit : nil)
                .padding(.vertical, 8)
                .padding(.horizontal, 11)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                    #if os(macOS)
                        .fill(.background.quinary)
                    #else
                        .fill(.background.secondary)
                    #endif
                        .fill(conversation.group?.session?.inputManager.editingIndex == indexOfConversationGroup ? Color.accentColor.opacity(0.1) : .clear)
                )
            
    #if os(macOS)
            contextMenu
    #endif
        }
        .padding(.leading, leadingPadding)
        #if !os(macOS)
        .contextMenu {
            if let group = conversation.group {
                ConversationMenu(group: group, isExpanded: $isExpanded, toggleTextSelection: toggleTextSelection)
            }
        } preview: {
            Text("User Message")
                .padding()
        }
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: conversation.content)
        }
        #else
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        #endif
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    @ViewBuilder
    var contextMenu: some View {
        if let group = conversation.group {
            ConversationMenu(group: group, isExpanded: $isExpanded)
                .symbolEffect(.appear, isActive: !isHovered)
        }
    }
    
    func toggleTextSelection() {
        showingTextSelection.toggle()
    }
    
    var leadingPadding: CGFloat {
        #if os(macOS)
        160
        #else
        60
        #endif
    }
    
    var lineLimit: Int {
        #if os(macOS)
        15
        #else
        6
        #endif
    }
    
    var indexOfConversationGroup: Int {
        conversation.group?.session?.groups.firstIndex(where: { $0 == conversation.group }) ?? 0
    }
    
    private var maxImageSize: CGFloat {
        300
    }
}

#Preview {
    UserMessage(conversation: .mockUserConversation)
        .frame(width: 500, height: 300)
}
