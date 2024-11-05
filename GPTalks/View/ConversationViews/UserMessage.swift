//
//  UserMessage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct UserMessage: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(ChatVM.self) private var sessionVM
    @Environment(\.isSearch) var isSearch
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var conversation: Thread
    @State var isHovered: Bool = false
    @State var isExpanded: Bool = false
    @State var showingTextSelection = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 7) {
            if !conversation.dataFiles.isEmpty {
                DataFilesView(dataFiles: $conversation.dataFiles, isCrossable: false)
            }
            
            GroupBox {
                HighlightedText(text: String(conversation.content.prefix(isExpanded || isSearch ? .max : 400)), highlightedText: sessionVM.searchText.count > 3 ? sessionVM.searchText : nil)
                    .font(.system(size: config.fontSize))
                    #if os(macOS)
                    .lineSpacing(2)
                    .padding(5)
                    #endif
            }
            .groupBoxStyle(PlatformSpecificGroupBoxStyle())
            .background(
                    (conversation.group?.session?.inputManager.editingIndex == indexOfThreadGroup ? Color.accentColor.opacity(0.1) : .clear)
            )
            
            #if os(macOS)
            contextMenu
            #endif
        }
        .padding(.leading, leadingPadding)
        #if !os(macOS)
        .contextMenu {
            if let group = conversation.group {
                ThreadMenu(group: group, isExpanded: $isExpanded, toggleTextSelection: toggleTextSelection)
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
            ThreadMenu(group: group, isExpanded: $isExpanded)
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
    
    var indexOfThreadGroup: Int {
        conversation.group?.session?.groups.firstIndex(where: { $0 == conversation.group }) ?? 0
    }
    
    private var maxImageSize: CGFloat {
        300
    }
}

#Preview {
    UserMessage(conversation: .mockUserThread)
        .frame(width: 500, height: 300)
}
