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
    
    @FocusState private var isFocused: FocusedField?
    
    private var matchingMessages: [Message] {
        guard !chatVM.searchText.isEmpty else { return [] }
        return chat.messages.enumerated().compactMap { index, message in
            message.content.localizedCaseInsensitiveContains(chatVM.searchText) ? message : nil
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
        if !matchingMessages.isEmpty {
            ToolbarItem {
                Text("\(currentSearchIndex + 1)/\(matchingMessages.count)")
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
                    .disabled(currentSearchIndex >= matchingMessages.count - 1)
                }
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button("Tokens: \(String(format: "%.2fK", Double(chat.totalTokens) / 1000.0))") { }
                .allowsHitTesting(false)
        }
        
        
        ToolbarItemGroup(placement: .keyboard) {
            Section {
                Button("Edit Last Message") {
                    guard let lastUserMessage = chat.messages.last(where: { $0.role == .user }) else { return }
                    isFocused = .textEditor // this isnt doing anything (on macos at least)
                    chat.inputManager.setupEditing(message: lastUserMessage)
                }
                .keyboardShortcut("e")
                .disabled(chat.status == .quick)
                
                Button("Regen Last Message") {
                    if let last = lastMessage {
                        Task { @MainActor in
                            await chat.regenerate(message: last)
                        }
                    }
                }
                .keyboardShortcut("r")
            }
            
            Section {
                Button("Reset Context") {
                    if let last = lastMessage {
                        chat.resetContext(at: last)
                    }
                }
                .keyboardShortcut("k")
                
                Button("Delete Last Message", role: .destructive) {
                    if let last = lastMessage {
                        chat.deleteMessage(last)
                    }
                }
                .keyboardShortcut(.delete)
            }
        }
        
        
        #else
        if !chatVM.searchText.isEmpty {
            ToolbarItem {
                Button("Clear Search") {
                    chatVM.searchText = ""
                }
            }
        }
        #endif
    }
    
    private var lastMessage: Message? {
        guard !chat.isReplying,
              let lastMessage = chat.messages.last else { return nil }
        return lastMessage
    }
    
    private func toggleInspector() {
        #if !os(macOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
        showingInspector.toggle()
    }
    
    private func nextMatch() {
        guard currentSearchIndex < matchingMessages.count - 1 else { return }
        currentSearchIndex += 1
        scrollToCurrentMatch()
    }
    
    private func previousMatch() {
        guard currentSearchIndex > 0 else { return }
        currentSearchIndex -= 1
        scrollToCurrentMatch()
    }
    
    private func scrollToCurrentMatch() {
        guard currentSearchIndex >= 0 && currentSearchIndex < matchingMessages.count else { return }
        let message = matchingMessages[currentSearchIndex]
        AppConfig.shared.proxy?.scrollTo(message, anchor: .top)
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
