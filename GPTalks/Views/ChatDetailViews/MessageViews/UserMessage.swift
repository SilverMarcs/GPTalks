//
//  UserMessage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct UserMessage: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(ChatVM.self) private var chatVM
    @ObservedObject var config = AppConfig.shared
    
    var message: MessageGroup
    @State var isHovering: Bool = false
    @State var isExpanded: Bool = false
    @State var showingTextSelection = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 7) {
            if !message.dataFiles.isEmpty {
                DataFilesView(dataFiles: message.dataFiles)
            }
            
            GroupBox {
                HighlightableTextView(text: String(message.content.prefix(isExpanded || !chatVM.searchText.isEmpty  ? .max : 400)),
                                highlightedText: chatVM.searchText)
                    .textSelection(.enabled)
                    .font(.system(size: config.fontSize))
                    #if os(macOS)
                    .lineSpacing(2)
                    .padding(5)
                    #endif
            }
            .transaction { $0.animation = nil }
            .groupBoxStyle(PlatformGroupBoxStyle())
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        message.chat?.inputManager.editingIndex == indexOfMessage ? Color.accentColor.opacity(0.2) : .clear
                    )
            )
            
            #if os(macOS)
            contextMenu
            #endif
        }
        .padding(.leading, leadingPadding)
        #if !os(macOS)
        .contextMenu {
            MessageMenu(message: message, isExpanded: $isExpanded, toggleTextSelection: toggleTextSelection)
        }
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: message.content)
        }
        #else
        .onHover { isHovering = $0 }
        #endif
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    var contextMenu: some View {
        MessageMenu(message: message, isExpanded: $isExpanded)
            .symbolEffect(.appear, isActive: !isHovering)
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
    
    var indexOfMessage: Int {
        message.chat?.messages.firstIndex(where: { $0 == message }) ?? 0
    }
    
    private var maxImageSize: CGFloat {
        300
    }
}

#Preview {
    UserMessage(message: .mockUserGroup)
        .frame(width: 500, height: 300)
}
