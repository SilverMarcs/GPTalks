//
//  AssistantMessage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct AssistantMessage: View {
    @Environment(ChatVM.self) var chatVM
    
    @ObservedObject var config = AppConfig.shared
    
    var message: Message
    var group: MessageGroup
    var showMenu: Bool = true
    
    @State var height: CGFloat = 0
    @State private var showingTextSelection = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AssistantLabel(message: message)
                .transaction { $0.animation = nil }
                .padding(.leading, labelPadding)
            
            MDView(content: message.content, calculatedHeight: $height)
                .environment(\.searchText, chatVM.searchText)
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
                    SecondaryNavigationButtons(group: group)
                } else {
                    NavigationButtons(message: group)
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
        .contextMenu {
            MessageMenu(message: group) {
                showingTextSelection.toggle()
            }
        }
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
