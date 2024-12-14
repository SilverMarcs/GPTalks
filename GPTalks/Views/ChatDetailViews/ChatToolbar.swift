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
    
    var body: some ToolbarContent {
        ToolbarItem(placement: horizontalSizeClass == .compact ? .primaryAction : .navigation) {
            Button(action: toggleInspector) {
                Label("Shortcuts", systemImage: horizontalSizeClass == .compact ? "info.circle" : "slider.vertical.3")
            }
            .keyboardShortcut(".")
            .sheet(isPresented: $showingInspector) {
                ChatInspector(chat: chat)
                    .presentationDetents(horizontalSizeClass == .compact ? [.medium, .large] : [.large])
                    .presentationDragIndicator(.hidden)
            }
        }
        
        if horizontalSizeClass == .regular {
            ToolbarItem(placement: .primaryAction) {
                Button("Tokens: \(String(format: "%.2fK", Double(chat.totalTokens) / 1000.0))") { }
                    .allowsHitTesting(false)
            }
        }
        
        #if os(macOS)
        if chat.status == .temporary {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    chat.status = .normal
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
            }
        }
        
        ToolbarItemGroup(placement: .keyboard) {
            ModelSwitchButtons(chat: chat)
            
            Section {
                Button("Edit Last Message") {
                    guard let lastUserMessage = chat.currentThread.last(where: { $0.role == .user }) else { return }
                    isFocused = .textEditor // this isnt doing anything (on macos at least)
                    chat.inputManager.setupEditing(message: lastUserMessage)
                }
                .keyboardShortcut("e")
                .disabled(chat.status == .quick || chat.isReplying)
                
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
                    chat.deleteLastMessage()
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
    
    private var lastMessage: MessageGroup? {
        guard !chat.isReplying,
              let lastMessage = chat.currentThread.last else { return nil }
        return lastMessage
    }
    
    private func toggleInspector() {
        #if !os(macOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
        showingInspector.toggle()
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

#if os(macOS)
extension ToolbarItemPlacement {
    static let searchPanel = accessoryBar(id: "com.SilverMarcs.GPTalks.searchPanel")
}
#endif
