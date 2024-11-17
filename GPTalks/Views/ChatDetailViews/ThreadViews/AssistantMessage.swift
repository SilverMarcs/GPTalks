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
    var thread: Thread
    
    @State private var isHovering: Bool = false
    @State private var showingTextSelection = false
    @State private var dotOpacity: Double = 0.1  // Add a state variable for dot opacity
    
    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            Image(thread.provider?.type.imageName ?? "brain.SFSymbol")
                .resizable()
                .frame(width: 17, height: 17)
                .foregroundStyle(Color(hex: thread.provider?.color  ?? "#00947A").gradient)
                .transaction { $0.animation = nil }
            
            VStack(alignment: .leading, spacing: 7) {
                Text(thread.model?.name ?? "Assistant")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.secondary)
                    #if os(macOS)
                    .padding(.top, 2)
                    #endif
                    .transaction { $0.animation = nil }
                
//                if !chatVM.searchText.isEmpty {
//                    HighlightedText(text: thread.content, highlightedText: chatVM.searchText)
//                        .font(.system(size: config.fontSize))
//                        #if os(macOS)
//                        .lineSpacing(2)
//                        #endif
//                } else {
//                    MarkdownView(content: thread.content)
//                        .transaction { $0.animation = nil }
//                }
                
                MarkdownView(content: thread.content)
                    .transaction { $0.animation = nil }
                
                if !thread.dataFiles.isEmpty {
                    DataFilesView(dataFiles: thread.dataFiles, edge: .leading)
                }
                
                if thread.isReplying {
                    ProgressView()
                        .controlSize(.small)
                }
                
//                 chatgpt animation
//                if thread.isReplying && thread.content.isEmpty {
//                    Text("⬤")
//                        .opacity(dotOpacity)
//                        .onAppear {
//                            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
//                                dotOpacity = 1.0  // toggle between 0 and 1
//                            }
//                        }
//                }
                
                #if os(macOS)
                threadMenuView
                #endif
            }
        }
    #if !os(macOS)
    .contextMenu {
        if !thread.isReplying {
            ThreadMenu(thread: thread, isExpanded: .constant(true), toggleTextSelection: toggleTextSelection)
        }
    } preview: {
        Text("Assistant Message")
            .padding()
    }
    .sheet(isPresented: $showingTextSelection) {
        TextSelectionView(content: thread.content)
    }
    #else
    .onHover { isHovering = $0 }
    #endif
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 30)
    }

    @ViewBuilder
    var threadMenuView: some View {
        #if os(macOS)
        ThreadMenu(thread: thread, isExpanded: .constant(true))
            .symbolEffect(.appear, isActive: !isHovering)
            .opacity(thread.isReplying ? 0 : 1)
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
    AssistantMessage(thread: .mockAssistantThread)
        .frame(width: 500, height: 300)
}

