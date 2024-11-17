//
//  ChatToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ChatToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ChatVM.self) private var chatVM
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat
    
    @State private var showingInspector: Bool = false
    @State private var currentSearchIndex: Int = 0
    
    private var matchingThreads: [Thread] {
        guard !chatVM.searchText.isEmpty else { return [] }
        return chat.threads.enumerated().compactMap { index, thread in
            thread.content.localizedCaseInsensitiveContains(chatVM.searchText) ? thread : nil
        }
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: horizontalSizeClass == .compact ? .primaryAction : .navigation) {
            Button(action: toggleInspector) {
                Label("Shortcuts", systemImage: horizontalSizeClass == .compact ? "info.circle" : "slider.vertical.3")
            }
            .keyboardShortcut(".")
            .sheet(isPresented: $showingInspector) {
                ChatInspector(chat: chat)
                    #if os(macOS)
                    .frame(height: 659)
                    #endif
                    .presentationDetents(horizontalSizeClass == .compact ? [.medium, .large] : [.large])
                    .presentationDragIndicator(.hidden)
            }
        }
        
        #if os(macOS)
        if !matchingThreads.isEmpty {
            ToolbarItem {
                Text("\(currentSearchIndex + 1)/\(matchingThreads.count)")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            
            ToolbarItem {
                ControlGroup {
                    Button(action: previousMatch) {
                        Label("Previous match", systemImage: "chevron.left")
                    }
                    .disabled(currentSearchIndex <= 0)

                    Button(action: nextMatch) {
                        Label("Next match", systemImage: "chevron.right")
                    }
                    .disabled(currentSearchIndex >= matchingThreads.count - 1)
                }
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button("Tokens: \(String(format: "%.2fK", Double(chat.totalTokens) / 1000.0))") { }
                .allowsHitTesting(false)
        }
        #endif
    }
    
    private func toggleInspector() {
        #if !os(macOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
        showingInspector.toggle()
    }
    
    private func nextMatch() {
        guard currentSearchIndex < matchingThreads.count - 1 else { return }
        currentSearchIndex += 1
        scrollToCurrentMatch()
    }
    
    private func previousMatch() {
        guard currentSearchIndex > 0 else { return }
        currentSearchIndex -= 1
        scrollToCurrentMatch()
    }
    
    private func scrollToCurrentMatch() {
        guard currentSearchIndex >= 0 && currentSearchIndex < matchingThreads.count else { return }
        let thread = matchingThreads[currentSearchIndex]
        chat.proxy?.scrollTo(thread, anchor: .top)
    }
}

#Preview {
    VStack {
        Text("Hello, World!")
    }
    .frame(width: 700, height: 300)
    .toolbar {
        ChatToolbar(chat: .mockChat)
    }
}
