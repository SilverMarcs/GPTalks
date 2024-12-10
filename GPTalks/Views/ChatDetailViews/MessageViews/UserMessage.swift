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
        VStack(alignment: .trailing, spacing: 8) {
            if !message.dataFiles.isEmpty {
                DataFilesView(dataFiles: message.dataFiles)
            }
            
            GroupBox {
                VStack(alignment: .leading, spacing: 0) {
                    HighlightableTextView(displayedText, highlightedText: chatVM.searchText)
                        .textSelection(.enabled)
                        .font(.system(size: config.fontSize))
                        #if os(macOS)
                        .lineSpacing(2)
                        .padding(5)
                        #endif
                    
                    if shouldShowMoreButton {
                        Button {
                            isExpanded.toggle()
                            if !isExpanded {
                                Scroller.scroll(to: .top, of: message)
                            }
                        } label: {
                            Text(isExpanded ? "Less" : "More")
                                .font(.callout)
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 4)
                        .padding(.bottom, 2)
                    }
                }
            }
            .transaction { $0.animation = nil }
            .groupBoxStyle(PlatformGroupBoxStyle())
            .if(message.chat?.inputManager.editingMessage == self.message.activeMessage) {
                $0.background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.accentColor.opacity(0.2))
                )
            }
            
//            #if os(macOS)
//            if isHovering {
//                HoverableMessageMenu {
//                    MessageMenu(message: message) {
//                        showingTextSelection.toggle()
//                    }
//                }
//                .transition(.symbolEffect(.appear))
//            } else {
//                Color.clear.frame(height: 25)
//            }
//            #endif
        }
        .padding(.leading, leadingPadding)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: message.content)
        }
        .contextMenu {
            MessageMenu(message: message) {
                showingTextSelection.toggle()
            }
        }
    }
    
    var leadingPadding: CGFloat {
        #if os(macOS)
        160
        #else
        60
        #endif
    }
    
    private var displayedText: String {
        let maxCharacters = 400
        if isExpanded || !chatVM.searchText.isEmpty {
            return message.content
        } else {
            return String(message.content.prefix(maxCharacters))
        }
    }

    private var shouldShowMoreButton: Bool {
        message.content.count > 400 && chatVM.searchText.isEmpty
    }
}

#Preview {
    UserMessage(message: .mockUserGroup)
        .frame(width: 500, height: 300)
}
