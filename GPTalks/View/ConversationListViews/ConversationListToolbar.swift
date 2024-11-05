//
//  ConversationListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData

struct ConversationListToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ChatSessionVM.self) private var sessionVM
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var session: ChatSession
    
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
                ChatInspector(session: session)
                    .presentationDetents(horizontalSizeClass == .compact ? [.medium, .large] : [.large])
                    .presentationDragIndicator(.hidden)
            }
        }
        
        #if os(macOS)
        ToolbarItem(placement: .primaryAction) {
            Button("Tokens: \(session.tokenCount.formatToK())") { }
            .allowsHitTesting(false)
            .task {
                Task {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    session.refreshTokens()
                }
            }
        }
        
        if config.showStatusBar {
            ToolbarItem(placement: .favoritesBar) {
                ConversationStatusBar(session: session)
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
        ConversationListToolbar(session: .mockChatSession)
    }
}

#if os(macOS)
extension ToolbarItemPlacement {
    static let favoritesBar = accessoryBar(id: "conv-status-bar")
}
#endif
