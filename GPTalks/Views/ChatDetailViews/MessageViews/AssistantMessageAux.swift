//
//  AssistantMessageAux.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct AssistantMessageAux: View {
    @Environment(ChatVM.self) private var chatVM
    var message: Message
    var group: MessageGroup
    var showMenu: Bool = true
    
    @ObservedObject var config = AppConfig.shared
    
    @State var height: CGFloat = 0
    @State private var isHovering: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            Image(message.provider?.type.imageName ?? "brain.SFSymbol")
                .resizable()
                .frame(width: 17, height: 17)
                .foregroundStyle(Color(hex: message.provider?.color ?? "#00947A").gradient)
                .transaction { $0.animation = nil }
            
            VStack(alignment: .leading, spacing: 7) {
                Text(message.model?.name ?? "Assistant")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.secondary)
                    #if os(macOS)
                    .padding(.top, 2)
                    #endif
                    .transaction { $0.animation = nil }
                
                MarkdownView(content: message.content, calculatedHeight: $height)
                    .transaction { $0.animation = nil }
                    .if(config.markdownProvider == .webview) { view in
                        view
                            .frame(height: message.height, alignment: .top)
                            .onChange(of: height) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // without the delay window resizing adds extra space below
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
                if showMenu {
                    messageMenuView
                } else {
                    secondaryNavigateButtons
                }
                Spacer()
                #endif
            }
        }
        #if os(macOS)
        .onHover { isHovering = $0 }
        #endif
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 30)
    }
    
    var spacing: CGFloat {
        #if os(macOS)
        10
        #else
        7
        #endif
    }
    
    var messageMenuView: some View {
        MessageMenu(message: group, isExpanded: .constant(true))
            .symbolEffect(.appear, isActive: !isHovering)
            .opacity(message.isReplying ? 0 : 1)
    }
    
    @ViewBuilder
    var secondaryNavigateButtons: some View {
        if group.secondaryMessages.count > 1 {
            HStack {
                Button {
                    group.previousSecondaryMessage()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
                .disabled(!group.canGoToPreviousSecondary)
                .opacity(!group.canGoToPreviousSecondary ? 0.5 : 1)
                
                Button {
                    group.nextSecondaryMessage()
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
                .disabled(!group.canGoToNextSecondary)
                .opacity(!group.canGoToNextSecondary ? 0.5 : 1)
            }
            .buttonStyle(HoverScaleButtonStyle())
            .symbolEffect(.appear, isActive: !isHovering)
        }
    }
}
