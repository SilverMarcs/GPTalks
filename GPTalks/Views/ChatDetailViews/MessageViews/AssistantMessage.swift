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
    var message: Message
    
    @State private var isHovering: Bool = false
    @State private var showingTextSelection = false
    
    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            Image(message.provider?.type.imageName ?? "brain.SFSymbol")
                .resizable()
                .frame(width: 17, height: 17)
                .foregroundStyle(Color(hex: message.provider?.color  ?? "#00947A").gradient)
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
                messageMenuView
                #endif
            }
        }
        #if !os(macOS)
        .contextMenu {
            if !message.isReplying {
                MessageMenu(message: message, isExpanded: .constant(true), toggleTextSelection: toggleTextSelection)
            }
        } preview: {
            Text("Assistant Message")
                .padding()
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

    @ViewBuilder
    var messageMenuView: some View {
        #if os(macOS)
        MessageMenu(message: message, isExpanded: .constant(true))
            .symbolEffect(.appear, isActive: !isHovering)
            .opacity(message.isReplying ? 0 : 1)
        #endif
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
    AssistantMessage(message: .mockAssistantMessage)
        .frame(width: 500, height: 300)
}

