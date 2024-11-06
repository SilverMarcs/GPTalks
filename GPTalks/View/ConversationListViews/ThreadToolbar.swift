//
//  ThreadListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData

struct ThreadListToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ChatVM.self) private var chatVM
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat
    
    @State var showingInspector: Bool = false
    
    var body: some ToolbarContent {
        ToolbarItem(placement: horizontalSizeClass == .compact ? .primaryAction : .navigation) {
            Button {
                toggleInspector()
            } label: {
                Label("Shortcuts", systemImage: horizontalSizeClass == .compact ? "info.circle" : "slider.vertical.3")
            }
            .keyboardShortcut(".")
            .sheet(isPresented: $showingInspector) {
                ChatInspector(chat: chat)
                    #if os(macOS)
                    .frame(height: 625)
                    #endif
                    .presentationDetents(horizontalSizeClass == .compact ? [.medium, .large] : [.large])
                    .presentationDragIndicator(.hidden)
            }
        }
        
        #if os(macOS)
        ToolbarItem(placement: .primaryAction) {
            Button("Tokens: \(chat.tokenCount.formatToK())") { }
            .allowsHitTesting(false)
            .task {
                Task {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    chat.refreshTokens()
                }
            }
        }
        
        if config.showStatusBar {
            ToolbarItem(placement: .favoritesBar) {
                ThreadStatusBar(chat: chat)
                    .padding(.horizontal, 5)
            }
        }
        #endif
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
        ThreadListToolbar(chat: .mockChat)
    }
}

#if os(macOS)
extension ToolbarItemPlacement {
    static let favoritesBar = accessoryBar(id: "conv-status-bar")
}
#endif
