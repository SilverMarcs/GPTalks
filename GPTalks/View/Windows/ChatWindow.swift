//
//  MainWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/08/2024.
//

import SwiftUI
import KeyboardShortcuts

#if os(macOS)
struct ChatWindow: Scene {
    @Environment(ChatSessionVM.self) var chatVM
    @Environment(\.modelContext) var modelContext
    
    @State var isPresented = false
    @State var showAdditionalContent = false
    
    var body: some Scene {
        Window("Chats", id: "chats") {
            ChatContentView()
                .environment(\.isQuick, false)
                .withFloatingPanel(isPresented: $isPresented, showAdditionalContent: $showAdditionalContent)
        }
        .commands {
            ChatCommands()
        }
    }
}

struct FloatingPanelModifierHelper: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var showAdditionalContent: Bool
    @Environment(ChatSessionVM.self) var chatVM
    @Environment(\.modelContext) var modelContext
    
    func body(content: Content) -> some View {
        content
            .task {
                KeyboardShortcuts.onKeyDown(for: .togglePanel) {
                    isPresented.toggle()
                }
            }
            .floatingPanel(isPresented: $isPresented, showAdditionalContent: $showAdditionalContent) {
                QuickPanelHelper(isPresented: $isPresented, showAdditionalContent: $showAdditionalContent)
                    .environment(\.isQuick, true)
                    .environment(chatVM)
                    .modelContainer(modelContext.container)
            }
    }
}

extension View {
    func withFloatingPanel(isPresented: Binding<Bool>, showAdditionalContent: Binding<Bool>) -> some View {
        self.modifier(FloatingPanelModifierHelper(isPresented: isPresented, showAdditionalContent: showAdditionalContent))
    }
}
#endif
