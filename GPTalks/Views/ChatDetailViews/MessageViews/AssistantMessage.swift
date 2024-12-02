//
//  AssistantMessage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct AssistantMessage: View {
    @ObservedObject var config = AppConfig.shared
    
    var message: Message
    var group: MessageGroup
    var showMenu: Bool = true
    
    @State var height: CGFloat = 0
    @State private var showingTextSelection = false
    @State private var isHovering = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AssistantLabel(message: message)
                .transaction { $0.animation = nil }
                .padding(.leading, labelPadding)
            
            MarkdownView(content: message.content, calculatedHeight: $height)
                .environment(\.isReplying, message.isReplying)
                .transaction { $0.animation = nil }
                .if(config.markdownProvider == .webview) { view in
                    view
                        .frame(height: message.height, alignment: .top)
                        .onChange(of: height) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if height > 0 {
                                    message.height = height
                                }
                            }
                        }
                }
            
            if !message.dataFiles.isEmpty {
//                DataFilesView(dataFiles: message.dataFiles, edge: .leading)
                ForEach(message.dataFiles, id: \.self) { data in
                    ImageViewerData(data: data.data)
                }
            }
            
            if message.isReplying {
                ProgressView()
                    .controlSize(.small)
            }
            
            #if os(macOS)
            if !message.isReplying {
                if !showMenu {
                    HStack {
                        SecondaryNavigationButtons(group: group)
                    }
                } else {
                    if isHovering {
                        HoverableMessageMenu {
                            MessageMenu(message: group) {
                                showingTextSelection.toggle()
                            }
                        }
                    } else {
                        // Display a clear view of the same height as the menu
                        Color.clear.frame(height: 25)
                    }
                }
            }
            Spacer()
            #endif
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 25)
        .padding(.trailing, 30)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: message.content)
        }
        #if !os(macOS)
        .contextMenu {
            MessageMenu(message: group) {
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
    AssistantMessage(message: .mockAssistantMessage, group: .mockAssistantGroup)
        .environment(ChatVM())
        .frame(width: 600, height: 300)
}
