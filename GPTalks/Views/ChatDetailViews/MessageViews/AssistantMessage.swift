//
//  AssistantMessage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct AssistantMessage: View {
    @Environment(ChatVM.self) var chatVM
    @ObservedObject var config = AppConfig.shared
    var message: MessageGroup
    
    @State private var isHovering: Bool = false
    @State private var showingTextSelection = false
    
    var body: some View {
        #if os(macOS)
        if message.isSplitView {
            HStack {
                messageContent(message: message.activeMessage)
                
                Divider()
                
                if message.isSplitView {
                    messageContent(message: message.secondaryMessages[message.secondaryMessageIndex], showMenu: false)
                }
            }
        } else {
            messageContent(message: message.activeMessage)
        }
        #else
        messageContent(message: message.activeMessage)
        #endif
    }
    
    @ViewBuilder
    private func messageContent(message: Message, showMenu: Bool = true) -> some View {
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
                
                MarkdownView(content: message.content)
                    .transaction { $0.animation = nil }
                
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
                #endif
                
                Spacer()
            }
        }
        #if !os(macOS)
        .contextMenu {
            if !message.isReplying {
                MessageMenu(message: message, isExpanded: .constant(true), toggleTextSelection: toggleTextSelection)
            }
        }
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: message.content)
        }
        #else
        .onHover { isHovering = $0 }
        #endif
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 30)
    }
    
    var messageMenuView: some View {
        MessageMenu(message: message, isExpanded: .constant(true))
            .symbolEffect(.appear, isActive: !isHovering)
            .opacity(message.isReplying ? 0 : 1)
    }
    
    @ViewBuilder
    var secondaryNavigateButtons: some View {
        if message.secondaryMessages.count > 1 {
            HStack {
                Button {
                    message.previousSecondaryMessage()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
                .disabled(!message.canGoToPreviousSecondary)
                .opacity(!message.canGoToPreviousSecondary ? 0.5 : 1)
                
                Button {
                    message.nextSecondaryMessage()
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
                .disabled(!message.canGoToNextSecondary)
                .opacity(!message.canGoToNextSecondary ? 0.5 : 1)
            }
            .buttonStyle(HoverScaleButtonStyle())
            .symbolEffect(.appear, isActive: !isHovering)
        }
    }
    
    var spacing: CGFloat {
        #if os(macOS)
        10
        #else
        7
        #endif
    }
    
    func toggleTextSelection() {
        showingTextSelection.toggle()
    }
}

#Preview {
    AssistantMessage(message: .mockAssistantGroup)
        .frame(width: 500, height: 300)
}

