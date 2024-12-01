//
//  AssistantMessageAux.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct AssistantMessageAux: View {
    @ObservedObject var config = AppConfig.shared
    
    var message: Message
    var group: MessageGroup
    var showMenu: Bool = true
    
    @State var height: CGFloat = 0
    @State private var showingTextSelection = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AssistantLabel(message: message)
                .padding(.leading, labelPadding)
            
            MarkdownView(content: message.content, calculatedHeight: $height)
                .environment(\.isReplying, message.isReplying)
                .transaction { $0.animation = nil }
                .if(config.markdownProvider == .webview) { view in
                    view
                        .frame(height: message.height, alignment: .top)
                        .onChange(of: height) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                // without the delay window resizing adds extra space below
                                if height > 0   {
                                    message.height = height
                                }
                            }
                        }
                }
            
            if !message.dataFiles.isEmpty {
                DataFilesView(dataFiles: message.dataFiles, edge: .leading)
            }
            
            if message.isReplying {
                ProgressView()
                    .controlSize(.small)
            }
            
            #if os(macOS)
            if !message.isReplying {
                if !showMenu {
                    HStack(alignment: .center) {
                        SecondaryNavigationButtons(group: group)
                            .buttonStyle(.plain)
                            .labelStyle(.iconOnly)
                    }
                } else {
                    HStack(alignment: .center) {
                        Menu {
                            MessageMenu(message: group, isExpanded: .constant(true)) {
                                showingTextSelection.toggle()
                            }
                            .labelStyle(.titleOnly)
                        } label: {
                            Label("More", systemImage: "ellipsis.circle")
                        }
                        .fixedSize()
                        .menuIndicator(.hidden)
                        .labelStyle(.titleOnly)
                        .buttonStyle(.primaryBordered)
                        
                        NavigationButtons(message: group)
                            .buttonStyle(.plain)
                            .labelStyle(.iconOnly)
                    }
                }
            }  
            Spacer()
            #endif
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 25)
        .padding(.trailing, 30)
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: message.content)
        }
        #if !os(macOS)
        .contextMenu {
            MessageMenu(message: group, isExpanded: .constant(true)) {
                showingTextSelection.toggle()
            }
        }
        #endif
    }
    
    var labelPadding: CGFloat {
        #if os(macOS)
        return -22
        #else
        return -25
        #endif
    }
}

#Preview {
    AssistantMessageAux(message: .mockAssistantMessage, group: .mockAssistantGroup)
        .environment(ChatVM())
        .frame(width: 600, height: 300)
}
