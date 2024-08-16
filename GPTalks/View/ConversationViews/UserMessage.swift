//
//  UserMessage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct UserMessage: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var config = AppConfig.shared
    
    var conversation: Conversation
    @State var isHovered: Bool = false
    @State var isExpanded: Bool = false
    @State var showingTextSelection = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 7) {
            if !conversation.imagePaths.isEmpty {
                imageList
            }
            
            HighlightedText(text: conversation.content, highlightedText: conversation.group?.session?.searchText.count ?? 0 > 3 ? conversation.group?.session?.searchText : nil)
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
            if let group = conversation.group {
                ConversationMenu(group: group, isExpanded: $isExpanded)
                    .symbolEffect(.appear, isActive: !isHovered)
            }
            #endif
        }
        .padding(.leading, leadingPadding)
        #if !os(macOS)
        .contextMenu {
            if let group = conversation.group {
                ConversationMenu(group: group, labelSize: labelSize, toggleMaxHeight: toggleMaxHeight, isExpanded: isExpanded, toggleTextSelection: toggleTextSelection)
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
    
    var imageList: some View {
        ScrollView {
            HStack {
                ForEach(conversation.imagePaths, id: \.self) { imagePath in
                    ImageViewer(imagePath: imagePath, maxWidth: maxImageSize, maxHeight: maxImageSize, radius: 9, isCrossable: false) {
                            print("Should not be removed from here")
                        // TODO: make optional func var
                    }
                }
            }
        }
    }
    
    private var maxImageSize: CGFloat {
        300
    }
}

#Preview {
    let conversation = Conversation(
        role: .user, content: "Hello, World! who are you and how are you")

    UserMessage(conversation: conversation)
        .frame(width: 500, height: 300)
}
