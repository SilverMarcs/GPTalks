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

    @State var isExpanded: Bool = false
    @State var showingTextSelection = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 7) {
            if !message.dataFiles.isEmpty {
                DataFilesView(dataFiles: message.dataFiles)
            }
            
            GroupBox {
                HighlightableTextView(String(message.content.prefix(isExpanded || !chatVM.searchText.isEmpty  ? .max : 400)),
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
                        (message.chat?.inputManager.editingMessage == self.message.activeMessage) ?
                        Color.accentColor.opacity(0.2) :
                        .clear
                    )
            )
            
            #if os(macOS)
            HStack {
                NavigationButtons(message: message)
            }
            #endif
        }
        .padding(.leading, leadingPadding)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .contextMenu {
            MessageMenu(message: message, isExpanded: $isExpanded) {
                showingTextSelection.toggle()
            }
        }
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: message.content)
        }
    }
    
    var leadingPadding: CGFloat {
        #if os(macOS)
        160
        #else
        60
        #endif
    }
}

#Preview {
    UserMessage(message: .mockUserGroup)
        .frame(width: 500, height: 300)
}
